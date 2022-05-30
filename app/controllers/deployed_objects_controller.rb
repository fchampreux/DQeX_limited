class DeployedObjectsController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current business process
  before_action :set_business_object, except: [:create, :new, :index, :index_used, :derive]

  before_action :evaluate_completion, only: [:show, :propose, :accept, :reject, :reopen]

# Create the list of statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]

  # Create the list of data types to be used in the skills rows
  before_action :set_data_types_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /business_objects
  # GET /business_objects.json
  # Returns only Deployed (implemented) and Visible (active) business objects
  def index
    @business_objects = DeployedObject.joins(translated_objects).
                                      pgnd(current_playground).
                                      where("business_objects.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                      visible.
                                      select(index_fields).
                                      order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @business_objects }
      format.csv { send_data @business_objects.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /business_objects/1
  # GET /business_objects/1.json
  def show
    ### Retrieved by Callback function
    @create_table_ORACLE = SqlQuery.new(:create_table_ORACLE, target: @business_object, db_connection: :development)
    @load_table_ORACLE = SqlQuery.new(:load_table_ORACLE, target: @business_object, db_connection: :development)
    @create_table_SAS = SqlQuery.new(:create_table_SAS, target: @business_object, db_connection: :development)
    @load_table_SAS = SqlQuery.new(:load_table_SAS, target: @business_object, db_connection: :development)
    @load_SAS_to_ORACLE = SqlQuery.new(:load_SAS_to_ORACLE, target: @business_object, db_connection: :development)
    @validate_table_ORACLE = SqlQuery.new(:validate_table_ORACLE, target: @business_object, db_connection: :development)
    @linked_skills = DeployedObject.joins(linked_skills).where(id: @business_object).select(linked_skills_fields).order(linked_skills_order_by)
    #@validate_table = SqlQuery.new(:validate_table, target: @business_object, db_connection: :development)
    puts @create_table_ORACLE.pretty_sql
    puts @load_table_ORACLE.pretty_sql
    #puts @validate_table.pretty_sql

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @business_object.deployed_skills }
      format.csv { send_data @business_object.deployed_skills.to_csv }
      format.xlsx {render xlsx: "show", filename: "#{@business_object.code}_variables.xlsx", disposition: 'inline'}
    end
  end

  def export
  @linked_skills = DeployedObject.joins(linked_skills).where(id: @business_object).select(linked_skills_fields).order(linked_skills_order_by)
    render xlsx: "export", filename: "#{@business_object.code}_variables.xlsx", disposition: 'inline'
  end

  # GET /business_objects/new
  # GET /business_objects/new.json
  def new
    @parent = params[:parent_type].constantize.find(params[:parent_id])
    @business_object = @parent.deployed_objects.build(status_id: (statuses.find { |x| x["code"] == "NEW" }.id || 0), is_template: false)
    @child_skills = @business_object.deployed_skills.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)

    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @business_object.name_translations.build(field_name: 'name', language: locution.property)
      @business_object.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /business_objects/derive
  # Derive a business object (data structure) from a template business object
  def derive
    @template_object = DefinedObject.find(params[:template_id])
    @business_object = @template_object.becomes!(DeployedObject).deep_clone include: [:translations]
    @business_object.parent_type = params[:parent_class]
    @business_object.parent_id = params[:parent_id]
    @business_object.major_version = 0
    @business_object.minor_version = 0
    @business_object.is_finalised = false
    @business_object.is_template = false
    metadata_setup(@business_object) # User becomes owner of the new object
    # notifier les erreurs empêchant la sauvegarde
    # Remove DefinedObject prefix from code
    list_id = ParametersList.where("code=?", 'LIST_OF_OBJECT_TYPES').take!
    prefix = Parameter.find_by("parameters_list_id=? AND code=?", list_id, @template_object.class.name ).property
    @business_object.code = "#{@template_object.code[prefix.length+1..-1]}-#{Time.now.strftime("%Y%m%d:%H%M%S")}"
    # Si la sauvegarde fonctionne, créer les skills enfants
    if @business_object.save
      @template_object.defined_skills.each do |skill| # Duplicate associated skills too
        dup_skill = skill.becomes!(DeployedSkill).deep_clone include: [:translations]
        dup_skill.business_object_id = @business_object.id
        dup_skill.template_skill_id = skill.id
        dup_skill.is_template = false
        # Remove DefinedSkill prefix from code
        list_id = ParametersList.where("code=?", 'LIST_OF_OBJECT_TYPES').take!
        prefix = Parameter.find_by("parameters_list_id=? AND code=?", list_id, skill.class.name ).property
        dup_skill.code = "#{skill.code[prefix.length+1..-1]}-#{Time.now.strftime("%Y%m%d:%H%M%S")}"
        dup_skill.save
      end

      @child_skills = @business_object.deployed_skills.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      # edit the new object in html form
      redirect_to edit_deployed_object_path(@business_object), notice: t('BovCreated')  #'Business object version was successfully created.'
    else
      redirect_to @business_object, notice: t('UsedBoCreatedKO')  #'Used business object cannot be created.'
    end
  end


  # GET /business_objects/1/edit
  def edit
    ### Retrieved by Callback
    if @business_object.is_finalised
      redirect_to @business_object, notice: t('.Failure') #'Finalised Values list cannot be modified'
    end

    check_translations(@business_object)
    # It may be interesting to include this in a transaction in order to roll back new minor version creation if the user does not validate the update
    # Update or create new version:
    # If current user is different from the previous who updated the record, then create a new version.
    if (@business_object.updated_by != current_login) and $Versionning
      DefinedObject.without_callback(:create, :before, :set_hierarchy) do # avoid re-calculation of code and hierarchy
        @business_object_version = @business_object.deep_clone include: [:translations]
        @business_object_version.set_as_current(current_login) # Toggle current version
        @business_object_version.minor_version = @business_object.last_minor_version.next
        if @business_object_version.save
          @business_object.deployed_skills.each do |skill| # Duplicate associated skills too
            dup_skill = skill.deep_clone include: [:translations]
            dup_skill.business_object_id = @business_object_version.id
            dup_skill.save
          end
        end
      end
      @business_object = @business_object_version # Continue working with business object
      @child_skills = @business_object.deployed_skills.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end
  end

  # POST /business_objects
  # POST /business_objects.json
  def create
    @parent = deployed_object_params[:parent_type].constantize.find(deployed_object_params[:parent_id])
    @business_object = @parent.deployed_objects.build(deployed_object_params)
    @business_object.major_version = 0
    @business_object.minor_version = 0
    metadata_setup(@business_object)

    respond_to do |format|
      if @business_object.save
        format.html { redirect_to @business_object, notice: t('BoCreated') } #'Business object was successfully created.'
        format.json { render json: @business_object, status: :created, location: @business_object }
      else
        format.html { render action: "new" }
        format.json { render json: @business_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /business_objects/1
  # PUT /business_objects/1.json
  def update
    ### Retrieved by Callback function
    @business_object.updated_by = current_login

    # proceed with update
    respond_to do |format|
      if @business_object.update_attributes(deployed_object_params)
        format.html { redirect_to @business_object, notice: t('BOUpdated') } # 'Business object was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST - Opens the business object to receive shop around skills
  def open_cart
    session[:cart_id] = @business_object.id
    respond_to do |format|
      format.html { redirect_to @business_object, notice: t('BOCart') } # 'Business object is selected as shop around cart.'
      format.json { head :no_content }
    end
  end

  # POST - Closes the business object
  def close_cart
    session.delete(:cart_id)
    respond_to do |format|
      format.html { redirect_to @business_object, notice: t('BOClosed') } # 'Business object is closed.'
      format.json { head :no_content }
    end
  end

  # POST /business_objects/1
  # POST /business_objects/1.json
  def activate
    ### Retrieved by Callback function
    @business_object.set_as_active(current_login)

    respond_to do |format|
      if @business_object.save
          format.html { redirect_to @business_object, notice: t('BovRecalled') } #'Business object version was successfully recalled.'
          format.json { render json: @business_object, status: :created, location: @business_object }
        else
          format.html { redirect_to @business_object, notice: t('BovRecalledKO') } #'Business object vesion cannot be recalled.'
          format.json { render json: @business_object.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @business_object.set_as_inactive(current_login)
    respond_to do |format|
      format.html { redirect_to business_objects_url, notice: t('BODeleted') } # 'Business object was successfully deleted.'
      format.json { head :no_content }
    end
  end

  def script

  end

  def propose
    puts "-------------------------------------------------------"
    puts "------------------ PROPOSED ---------------------------"
    puts "-------------------------------------------------------"
    @business_object.submit!
    @business_object.update_attribute(:status_id, statuses.find { |x| x["code"] == "SUBMITTED" }.id || 0 )
    @notification = Notification.create(playground_id: current_playground, description: t('.DeployedObjectSubmitted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @business_object.parent.responsible_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @business_object.class.name, topic_id: @business_object.id, deputy_id: @business_object.parent.responsible_id, organisation_id: @business_object.organisation_id, code: @business_object.code, name: t('.DeployedObjectSubmitted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.DeployedObject')} #{@business_object.code} #{@business_object.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.DeployedObjectSubmitted')}")
  end

  def accept
    puts "-------------------------------------------------------"
    puts "------------------ ACCEPTED ---------------------------"
    puts "-------------------------------------------------------"
    @business_object.accept!
    @business_object.update_attributes(:status_id => statuses.find { |x| x["code"] == "ACCEPTED" }.id || 0, :is_finalised => true)
    @notification = Notification.create(playground_id: current_playground, description: t('.DeployedObjectAccepted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @business_object.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @business_object.class.name, topic_id: @business_object.id, deputy_id: @business_object.parent.responsible_id, organisation_id: @business_object.organisation_id, code: @business_object.code, name: t('.DeployedObjectAccepted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.DeployedObject')} #{@business_object.code} #{@business_object.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.DeployedObjectAccepted')}")
  end

  def reject
    # Reads the js answer
  end

  def reopen
    puts "-------------------------------------------------------"
    puts "------------------ REOPENED ---------------------------"
    puts "-------------------------------------------------------"
    @business_object.reopen!
    @business_object.update_attributes(:status_id => statuses.find { |x| x["code"] == "NEW" }.id || 0, :is_finalised => false)
    @notification = Notification.create(playground_id: current_playground, description: t('DeployedObjectReopened'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @business_object.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @business_object.class.name, topic_id: @business_object.id, deputy_id: @business_object.parent.parent.responsible_id, organisation_id: @business_object.organisation_id, code: @business_object.code, name: t('DeployedObjectReopened'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.DeployedObject')} #{@business_object.code} #{@business_object.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('DeployedObjectReopened')}")
  end

  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business object
    def set_business_object
      # Is it relevant to generate the child skills here and in other places in the contoller?
      @business_object = DeployedObject.pgnd(current_playground).includes(:owner, :status).find(params[:id])
      @child_skills = @business_object.deployed_skills.visible.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      @cloned_business_objects = DeployedObject.where("hierarchy = ?", @business_object.hierarchy )
      #dsd.deployed_skills.map { |v| "#{v.code} #{v.skill_type_id}(#{v.skill_size})" }.join(',')
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@business_object)
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

    def external_descriptions
      Translation.arel_table.alias('tr_extenal_descriptions')
    end

    def objects
      DeployedObject.arel_table
    end

    def defined_skills
      DefinedSkill.arel_table.alias('defined_skills')
    end

    def deployed_skills
      DeployedSkill.arel_table.alias('deployed_skills')
    end

    def values_lists
      ValuesList.arel_table.alias('values_lists')
    end

    def data_types
      Parameter.arel_table.alias('data_types')
    end

    def skill_roles
      Parameter.arel_table.alias('skill_roles')
    end

    def sensitivity
      Parameter.arel_table.alias('sensitivity')
    end

    def responsibles
      User.arel_table.alias('responsibles')
    end

    def organisations
      Organisation.arel_table
    end

    def translated_objects
      objects.
      join(owners).on(objects[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(objects[:id].eq(names[:document_id]).and(names[:document_type].eq("BusinessObject")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(objects[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("BusinessObject")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(external_descriptions, Arel::Nodes::OuterJoin).on(objects[:id].eq(external_descriptions[:document_id]).and(external_descriptions[:document_type].eq("BusinessObject")).and(external_descriptions[:language].eq(current_language).and(external_descriptions[:field_name].eq('external_description')))).
      join_sources
    end

    def index_fields
      [objects[:id], objects[:code], objects[:hierarchy], objects[:name], objects[:description], objects[:major_version], objects[:minor_version], objects[:status_id], objects[:updated_by], objects[:updated_at], objects[:is_active], objects[:is_current], objects[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not business_objects.is_active then '0'
          when business_objects.is_active and business_objects.is_finalised then '1'
          else '2'
	        end").as("calculated_status")]
    end

    def order_by
      [objects[:hierarchy].asc, objects[:major_version], objects[:minor_version]]
    end

    def linked_skills
      objects.
      join(deployed_skills).on(objects[:id].eq(deployed_skills[:business_object_id])).
      join(defined_skills).on(defined_skills[:id].eq(deployed_skills[:template_skill_id])).
      join(values_lists, Arel::Nodes::OuterJoin).on(deployed_skills[:values_list_id].eq(values_lists[:id])).
      join(data_types).on(data_types[:id].eq(deployed_skills[:skill_type_id])).
      join(skill_roles).on(skill_roles[:id].eq(deployed_skills[:skill_role_id])).
      join(sensitivity).on(sensitivity[:id].eq(deployed_skills[:sensitivity_id])).
      join(responsibles).on(responsibles[:id].eq(deployed_skills[:responsible_id])).
      join(organisations).on(organisations[:id].eq(deployed_skills[:organisation_id])).
      join_sources
    end

    def linked_skills_fields
      [objects[:id], objects[:code], defined_skills[:id].as("defined_variable_id"),
                                    defined_skills[:global_identifier].as("defined_variable_uuid"),
                                    defined_skills[:code].as("defined_variable_code"),
                                    deployed_skills[:id].as("used_variable_id"),
                                    deployed_skills[:global_identifier].as("used_variable_uuid"),
                                    deployed_skills[:code].as("used_variable_code"),
                                    deployed_skills[:skill_size].as("used_variable_size"),
                                    deployed_skills[:skill_precision].as("used_variable_precision"),
                                    deployed_skills[:is_mandatory].as("used_variable_mandatory"),
                                    skill_roles[:property].as("used_variable_role"),
                                    deployed_skills[:is_published].as("used_variable_published"),
                                    sensitivity[:property].as("used_variable_sensitive"),
                                    deployed_skills[:min_value].as("used_variable_min"),
                                    deployed_skills[:max_value].as("used_variable_max"),
                                    deployed_skills[:is_pairing_key].as("used_variable_pairing"),
                                    objects[:code].as("used_variable_dsd"),
                                    deployed_skills[:filter].as("used_variable_filter"),
                                    values_lists[:code].as("values_list_code"),
                                    data_types[:code].as("data_type"),
                                    responsibles[:user_name].as("used_variable_responsible"),
                                    organisations[:code].as("used_variable_organisation")]
    end

    def linked_skills_order_by
      [defined_skills[:code].asc, deployed_skills[:code].asc]
    end

  ### strong parameters
    def deployed_object_params
      params.require(:deployed_object).permit(:code, :name, :status_id, :pcf_index, :pcf_reference, :description, :granularity_id, :period, :ogd_id,
          :tr_name, :tr_description, :parent_type, :parent_id, :parent_class, :active_from, :active_to, :is_template,
          :organisation_id, :responsible_id, :deputy_id, :external_description, :reviewed_by, :reviewed_at, :approved_by, :approved_at,
          :uuid, :connection_id,
        skills_attributes:[:code, :name, :description, :is_pk, :is_published, :skill_type_id, :skill_size, :skill_precision, :_destroy, :id,
        name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy]],
        name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        annotations_attributes: [:playground_id, :value_id, :annotation_type_id,  :uri, :code, :name, :id, :_destroy,
          description_translations_attributes: [:id, :field_name, :language, :translation, :_destroy]],
        :participant_ids => [])
    end

    def evaluate_completion
      @completion_status = Array.new
      # translations
      @completion_status[0] = (1 - Translation.where("document_type = 'BusinessObject' and document_id = ? and field_name = 'name' and translation = '' ", @business_object.id).count.to_f / list_of_languages.length) * 100.00
      # values_list reference
      @completion_status[1] = nil
      # linked variables
      @completion_status[2] = ((@business_object.deployed_skills.map { |r| Skill.find(r.template_skill_id).is_finalised ? 1.0 : 0.0 }.reduce(:+) / @business_object.deployed_skills.count) * 100) if @business_object.deployed_skills.any?
      # responsibilities
      @completion_status[3] = ((@business_object.organisation_id != 0 ? 1 : 0) + (@business_object.responsible_id != 0 ? 1 : 0) + (@business_object.deputy_id != 0 ? 1 : 0)).to_f / 3 * 100.00
      # data types completion / consitency
      @completion_status[4] = nil
      # existence of Primary Key
      @completion_status[5] = @business_object.deployed_skills.any? ? (@business_object.deployed_skills.map { |r| (r.skill_role_id == options_for('skill_roles').find { |x| x["code"] == "DIM" }.id) ? 1.0 : 0.0 }.reduce(:+) >= 1 ? 100 : 0) : 0
    end

end
