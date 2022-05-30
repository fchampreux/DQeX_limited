class BusinessRulesController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current business rule
  #before_action :set_business_rule, only: [:show, :edit, :update, :destroy, :new_version, :make_current]
  before_action :set_business_rule, except: [:create, :new, :index]

  before_action :evaluate_completion, only: [:show, :propose, :accept, :reject, :reopen]

  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

# Create the selection lists be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]
  before_action :set_rule_types_list, only: [:new, :edit, :update, :create]
  #before_action :set_rule_classes_list, only: [:new, :edit, :update, :create]
  before_action :set_business_objects_list, only: [:new, :edit, :update, :create]
  before_action :set_severity_list, only: [:new, :edit, :update, :create]
  before_action :set_complexity_list, only: [:new, :edit, :update, :create]


  # GET /business_rules
  # GET /business_rules.json
  def index
    # Filtering by parent_id allows to use the same index in parent/child show view
    @business_rules = BusinessRule.joins(translated_rules).
                                    pgnd(current_playground).
                                    visible.
                                    where("business_rules.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                    where("business_rules.business_object_id in(?) or ? is null",params[:my_parent], params[:my_parent]).
                                    select(index_fields).
                                    order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @business_rules }
      format.csv { send_data @business_rules.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /business_rules/1
  # GET /business_rules/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /business_rules/new
  # GET /business_rules/new.json
  def new
    @business_object = BusinessObject.find(params[:deployed_object_id])
    @business_rule = BusinessRule.new(status_id: 1, playground_id: @business_object.playground_id, owner_id: current_user.id )
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @business_rule.name_translations.build(field_name: 'name', language: locution.property)
      @business_rule.description_translations.build(field_name: 'description', language: locution.property)
      @business_rule.business_value_translations.build(field_name: 'business_value', language: locution.property)
      @business_rule.check_description_translations.build(field_name: 'check_description', language: locution.property)
      @business_rule.correction_method_translations.build(field_name: 'correction_method', language: locution.property)
      @business_rule.check_error_message_translations.build(field_name: 'check_error_message', language: locution.property)
    end
  end

  # POST /business_rules/new_version
  def new_version # to add : Make sure this is current version, otherwise quit and notify
    BusinessRule.without_callback(:create, :before, :set_hierarchy) do # avoid re-calculation of code and hierarchy
      @business_rule_version = @business_rule.deep_clone include: [:translations]
      @business_rule_version.set_as_current(current_login) # Toggle current version
      @business_rule_version.major_version = @business_rule.last_version.next
      @business_rule_version.minor_version = 0
      @business_rule_version.is_finalised = false
      metadata_setup(@business_rule_version) # User becomes owner of the new version
      Task.without_callback(:create, :before, :set_hierarchy) do # avoid re-calculation of code and hierarchy
        @business_rule.tasks.each do |task| # Duplicate associated tasks too
          dup_task = task.deep_clone include: [:translations]
          dup_task.todo_id = @business_rule_version.id
          dup_task.save
        end
      end
      @business_rule = @business_rule_version # ontinue working with business rule

      # If save is successful, render the show view, other wise render error messages
      respond_to do |format|
        if @business_rule.save
          format.html { redirect_to @business_rule, notice: t('BRCreated') } #'Business rule version was successfully created.'
          format.json { render json: @business_rule, status: :created, location: @business_rule }
        else
          format.html { redirect_to @business_rule, notice: t('BRCreatedKO') } #'Business rule vesion cannot be created.'
          format.json { render json: @business_rule.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /business_rules/make_current # make this version the current version
  def make_current # Make sure this is not current version, otherwise quit and notify
    BusinessRule.without_callback(:create, :before, :set_hierarchy) do
      @business_rule.set_as_current(current_login) # Toggle current version
      @business_rule.updated_by = current_login

      respond_to do |format|
        if @business_rule.save
          format.html { redirect_to @business_rule, notice: t('BRSelected') } #'Business rule version was successfully selected.'
          format.json { render json: @business_rule, status: :created, location: @business_rule }
        else
          format.html { redirect_to @businessattributes_rule, notice: t('BRSelectedKO') } #'Business rule vesion cannot be selected.'
          format.json { render json: @business_rule.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /business_rules/finalise # flgs this version as finalised
  def finalise # Make sure this is not current version, otherwise quit and notify
    BusinessRule.without_callback(:create, :before, :set_hierarchy) do
      @business_rule.set_as_finalised(current_login) # Toggle current version
      @business_rule.updated_by = current_login

      respond_to do |format|
        if @business_rule.save
          format.html { redirect_to @business_rule, notice: t('BRFinalised') } #'Business rule version was successfully finalised.'
          format.json { render json: @business_rule, status: :created, location: @business_rule }
        else
          format.html { redirect_to @business_rule, notice: t('BRFinalisedKO') } #'Business rule vesion cannot be finalised.'
          format.json { render json: @business_rule.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  # GET /business_rules/1/edit
  def edit
    ### Retrieved by Callback function

    ### Finalised business rule cannot be modified
    if @business_rule.is_finalised
      redirect_to @business_rule, notice: t('BRFinModKO') #'Finalised Business Rule cannot be modified'
    end

    check_translations(@business_rule)
    # It may be interesting to include this in a transaction in order to roll back new minor version creation if the user does not validate the update
    # Update or create new version:
    # If current user is different from the previous who updated the record, then create a new version.
    if @business_rule.updated_by != current_login and $Versionning
      BusinessRule.without_callback(:create, :before, :set_hierarchy) do # avoid re-calculation of code and hierarchy
        @business_rule_version = @business_rule.deep_clone include: [:translations]
        @business_rule_version.set_as_current(current_login) # Toggle current version
        @business_rule_version.minor_version = @business_rule.last_minor_version.next

        Task.without_callback(:create, :before, :set_hierarchy) do # avoid re-calculation of code and hierarchy
          @business_rule.tasks.each do |task| # Duplicate associated tasks too
            dup_task = task.deep_clone include: [:translations]
            dup_task.todo_id = @business_rule_version.id
            dup_task.save
          end
        end
      end
      @business_rule_version.save! # save created version with updated attributes
      @business_rule = @business_rule_version
    end

  end

  # POST /business_rules
  # POST /business_rules.json
  def create
    @business_object = BusinessObject.find(params[:deployed_object_id])
    @business_rule = @business_object.business_rules.build(business_rule_params)
    @business_rule.major_version = 0
    @business_rule.minor_version = 0
    metadata_setup(@business_rule)

    respond_to do |format|
      if @business_rule.save
        format.html { redirect_to @business_rule, notice: t('BRCreated') } #'Business rule was successfully created.'
        format.json { render json: @business_rule, status: :created, location: @business_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @business_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /business_rules/1
  # PUT /business_rules/1.json
  def update
    ### Retrieved by Callback function

    # proceed with update
    respond_to do |format|
      if @business_rule.update(business_rule_params)
        format.html { redirect_to @business_rule, notice: t('BRUpdated') } #'Business rule was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /business_rules/1
  # POST /business_rules/1.json
  def activate
    ### Retrieved by Callback function
    @business_rule.set_as_active(current_login)

    respond_to do |format|
      if @business_rule.save
          format.html { redirect_to @business_rule, notice: t('BRRecalled') } #'Business rule version was successfully recalled.'
          format.json { render json: @business_rule, status: :created, location: @business_rule }
        else
          format.html { redirect_to @business_rule, notice: t('BRRecalledKO') } #'Business rule vesion cannot be recalled.'
          format.json { render json: @business_rule.errors, status: :unprocessable_entity }
      end
    end
  end

def destroy
  @business_rule.set_as_inactive(current_login)
  respond_to do |format|
    format.html { redirect_to business_rules_url, notice: t('BRDeleted') } #'Business rule was successfully deleted.'
    format.json { head :no_content }
  end
end

  def propose
    puts "-------------------------------------------------------"
    puts "------------------ PROPOSED ---------------------------"
    puts "-------------------------------------------------------"
    @business_rule.submit!
    @business_rule.update_attribute(:status_id, statuses.find { |x| x["code"] == "SUBMITTED" }.id || 0 )
    @notification = Notification.create(playground_id: current_playground, description: t('.DeployedObjectSubmitted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @business_rule.parent.responsible_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @business_rule.class.name, topic_id: @business_rule.id, deputy_id: @business_rule.parent.responsible_id, organisation_id: @business_rule.organisation_id, code: @business_rule.code, name: t('.DeployedObjectSubmitted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.DeployedObject')} #{@business_rule.code} #{@business_rule.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.DeployedObjectSubmitted')}")
  end

  def accept
    puts "-------------------------------------------------------"
    puts "------------------ ACCEPTED ---------------------------"
    puts "-------------------------------------------------------"
    @business_rule.accept!
    @business_rule.update_attributes(:status_id => statuses.find { |x| x["code"] == "ACCEPTED" }.id || 0, :is_finalised => true)
    @notification = Notification.create(playground_id: current_playground, description: t('.DeployedObjectAccepted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @business_rule.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @business_rule.class.name, topic_id: @business_rule.id, deputy_id: @business_rule.parent.responsible_id, organisation_id: @business_rule.organisation_id, code: @business_rule.code, name: t('.DeployedObjectAccepted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.DeployedObject')} #{@business_rule.code} #{@business_rule.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.DeployedObjectAccepted')}")
  end

  def reject
    # Reads the js answer
  end

  def reopen
    puts "-------------------------------------------------------"
    puts "------------------ REOPENED ---------------------------"
    puts "-------------------------------------------------------"
    @business_rule.reopen!
    @business_rule.update_attributes(:status_id => statuses.find { |x| x["code"] == "NEW" }.id || 0, :is_finalised => false)
    @notification = Notification.create(playground_id: current_playground, description: t('DeployedObjectReopened'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @business_rule.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @business_rule.class.name, topic_id: @business_rule.id, deputy_id: @business_rule.parent.parent.responsible_id, organisation_id: @business_rule.organisation_id, code: @business_rule.code, name: t('DeployedObjectReopened'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.DeployedObject')} #{@business_rule.code} #{@business_rule.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('DeployedObjectReopened')}")
  end

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business rule
    def set_business_rule
      @business_rule = BusinessRule.pgnd(current_playground).includes(:owner, :status).find(params[:id])
      @business_object = @business_rule.parent
      @cloned_business_rules = BusinessRule.where("hierarchy = ?", @business_rule.hierarchy )
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@business_rule)
    end

    # Retrieve business objects list
    def set_business_objects_list
      if (action_name == 'edit' or action_name == 'update')
        my_business_area = @business_rule.parent.parent.parent.id
      else
        my_business_area = BusinessObject.find(params[:deployed_object_id]).parent.parent.id
      end
      @business_objects_list = DeployedObject.where("business_area_id = ?", my_business_area) || DeployedObject.find(0)
    end

  ### queries tayloring
  def owners
    User.arel_table.alias('owners')
  end

  def names
    Translation.arel_table.alias('tr_names')
  end

  def descriptions
    Translation.arel_table.alias('tr_descriptions')
  end

  def rules
    BusinessRule.arel_table
  end

  def skills
    Skill.arel_table
  end

  def objects
    BusinessObject.arel_table
  end

  def translated_rules
    rules.
    join(owners).on(rules[:owner_id].eq(owners[:id])).
    join(names, Arel::Nodes::OuterJoin).on(rules[:id].eq(names[:document_id]).and(names[:document_type].eq("BusinessRule")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
    join(descriptions, Arel::Nodes::OuterJoin).on(rules[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("BusinessRule")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
    join(skills).on(rules[:skill_id].eq(skills[:id])).
    join(objects).on(rules[:business_object_id].eq(objects[:id])).
    join_sources
  end

  def index_fields
    [rules[:id], rules[:code], rules[:hierarchy], rules[:name], rules[:description], rules[:major_version], rules[:minor_version],
      rules[:status_id], rules[:updated_by], rules[:updated_at], rules[:is_active], rules[:is_current], rules[:is_finalised],
      rules[:ordering_sequence],
      owners[:name].as("owner_name"),
      names[:translation].as("translated_name"),
      descriptions[:translation].as("translated_description"),
      Arel::Nodes::SqlLiteral.new("case
      when not business_rules.is_active then '0'
      when business_rules.is_active and business_rules.is_finalised then '1'
      else '2'
      end").as("calculated_status"),
      Arel::Nodes::NamedFunction.new('concat', [
      objects[:code],
      Arel::Nodes.build_quoted('.'),
      skills[:code]]).as("object_type")
    ]
  end

  def order_by
    [rules[:hierarchy].asc,rules[:major_version], rules[:minor_version]]
  end

  ### strong parameters
  def business_rule_params
    params.require(:business_rule).permit(:id, :name, :code, :status_id, :description, :business_value, :check_description, :check_script, :check_error_message,
        :correction_method, :correction_script, :white_list, :rule_type_id, :rule_class_id, :condition, :complexity_id, :added_value, :severity_id,
        :maintenance_cost, :maintenance_duration, :version, :business_object_id, :skill_id,  :field_name, :ordering_sequence, :is_published,
        :valid_from, :valid_to, :tag_list, :organisation_id, :responsible_id, :deputy_id, :check_language_id, :correction_language_id,
      tasks_attributes:[:id, :name, :code, :description, :status_id, :is_active, :pcf_index, :pcf_reference, :external_reference, :script, :language_id, :task_type_id,
                        :playground_id, :owner_id],
      name_translations_attributes:[:id, :field_name, :language, :translation],
      description_translations_attributes:[:id, :field_name, :language, :translation],
      business_value_translations_attributes:[:id, :field_name, :language, :translation],
      check_description_translations_attributes:[:id, :field_name, :language, :translation],
      check_error_message_translations_attributes:[:id, :field_name, :language, :translation],
      correction_method_translations_attributes:[:id, :field_name, :language, :translation])
  end

  def evaluate_completion
    @completion_status = Array.new
    # translations
    @completion_status[0] = (1 - Translation.where("document_type = 'BusinessRule' and document_id = ? and field_name = 'name' and translation = '' ", @business_rule.id).count.to_f / list_of_languages.length) * 100.00
    # values_list reference
    @completion_status[1] = nil
    # linked variables
    @completion_status[2] = nil
    # responsibilities
    @completion_status[3] = ((@business_rule.organisation_id != 0 ? 1 : 0) + (@business_rule.responsible_id != 0 ? 1 : 0) + (@business_rule.deputy_id != 0 ? 1 : 0)).to_f / 3 * 100.00
    # data types completion / consitency
    @completion_status[4] = nil
    # existence of Primary Key
    @completion_status[5] = nil
  end

end
