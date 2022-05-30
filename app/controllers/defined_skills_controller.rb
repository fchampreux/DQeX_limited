class DefinedSkillsController < ApplicationController
  # Check for active session
    before_action :authenticate_user!
    load_and_authorize_resource

  # Retrieve current skill
  #  before_action :set_skill, only: [:show, :edit, :update, :destroy, :create_values_list, :upload_values_list, :remove_values_list]
    before_action :set_skill, except: [:new, :create, :index, :add_to_cart, :list ]

    before_action :evaluate_completion, only: [:show, :propose, :accept, :reject, :reopen]

  # Create the list of statuses to be used in the form
  #  before_action :set_statuses_list

    # Create the list of data types to be used in the skills rows
  #  before_action :set_data_types_list
  #  before_action :set_other_languages

    # Initialise breadcrumbs for the resulting view
    before_action :set_breadcrumbs, only: [:show, :edit, :update]

  def index
    @skills = DefinedSkill.joins(translated_skills).
                            pgnd(current_playground).
                            visible.
                            where("skills.owner_id = ? or ? is null", params[:owner], params[:owner]).
                            search(params[:criteria]).
                            select(index_fields).
                            order(order_by).
                            paginate(page: params[:page], :per_page => params[:per_page])

      respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @skills }
      format.csv { send_data @skills.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def list
    @skills = skills_by_theme
     render json: @skills
  end

  def show
    # skill retrieved by callback

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @skill }
      format.csv { send_data @skill.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def new
    @business_object = DefinedObject.find(params[:defined_object_id])
    @skill = @business_object.defined_skills.build(playground_id: @business_object.playground_id, is_template: @business_object.is_template, responsible_id: current_user.id, organisation_id: current_user.organisation_id )
    list_of_languages.each do |locution|
      @skill.name_translations.build(field_name: 'name', language: locution.property)
      @skill.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  def edit
    # skill retrieved by callback

    ### Finalised Skill cannot be modified
    if @skill.is_finalised
      redirect_to @skill, notice: t('.Failure') #'Finalised Values list cannot be modified'
    end
    check_translations(@skill)
  end

  def propose
    puts "-------------------------------------------------------"
    puts "------------------ PROPOSED ---------------------------"
    puts "-------------------------------------------------------"
    @skill.submit!
    @skill.update_attribute(:status_id, statuses.find { |x| x["code"] == "SUBMITTED" }.id || 0 )
    @notification = Notification.create(playground_id: current_playground, description: t('SkillSubmitted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @skill.parent.parent.reviewer_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @skill.class.name, topic_id: @skill.id, deputy_id: @skill.parent.parent.responsible_id, organisation_id: @skill.organisation_id, code: @skill.code, name: t('SkillSubmitted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('Skill')} #{@skill.code} #{@skill.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('SkillSubmitted')}")
  end

  def accept
    puts "-------------------------------------------------------"
    puts "------------------ ACCEPTED ---------------------------"
    puts "-------------------------------------------------------"
    @skill.accept!
    @skill.update_attributes(:status_id => statuses.find { |x| x["code"] == "ACCEPTED" }.id || 0, :is_finalised => true)
    @notification = Notification.create(playground_id: current_playground, description: t('SkillAccepted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @skill.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @skill.class.name, topic_id: @skill.id, deputy_id: @skill.parent.parent.responsible_id, organisation_id: @skill.organisation_id, code: @skill.code, name: t('SkillAccepted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('Skill')} #{@skill.code} #{@skill.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('SkillAccepted')}")
  end

  def reject
    # Reads the js answer
  end

  def reopen
    puts "-------------------------------------------------------"
    puts "------------------ REOPENED ---------------------------"
    puts "-------------------------------------------------------"
    @skill.reopen!
    @skill.update_attributes(:status_id => statuses.find { |x| x["code"] == "NEW" }.id || 0, :is_finalised => false)
    @notification = Notification.create(playground_id: current_playground, description: t('SkillReopened'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @skill.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @skill.class.name, topic_id: @skill.id, deputy_id: @skill.parent.parent.responsible_id, organisation_id: @skill.organisation_id, code: @skill.code, name: t('SkillReopened'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('Skill')} #{@skill.code} #{@skill.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('SkillReopened')}")
  end

  def update
    # skill retrieved by callback
    if params[:anything]
      @skill.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @skill.anything = nil
    end
    @skill.updated_by = current_login

    respond_to do |format|
      if @skill.update_attributes(defined_skill_params)
        format.html { redirect_to @skill, notice: t('.Success') } #'Skill was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit", notice: t('.Failure')  }
        format.json { render json: @skill.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @business_object = DefinedObject.find(params[:defined_object_id])
    @skill = @business_object.defined_skills.build(defined_skill_params)
    if params[:anything]
      @skill.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @skill.anything = nil
    end
    @skill.status_id = statuses.find { |x| x["code"] == "NEW" }.id || 0
    metadata_setup(@skill)

    respond_to do |format|
      if @skill.save
        format.html { redirect_to @skill, notice: t('.Success') } #'Skill was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "new", notice: t('.Failure')  }
        format.json { render json: @skill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /skills/1
  # DELETE /skills/1.json
  def destroy
    # skill retrieved by callback
    # @skill.destroy -- do not delete a defined variable as a deployed one car refer to it
    @skill.set_as_inactive(current_login)

    respond_to do |format|
      format.html { redirect_to @skill.parent, notice: t('.Success') } #'Skill was successfully removed.'
      format.json { head :no_content }
    end

  end

  def activate
    ### Retrieved by Callback function
    @skill.set_as_active(current_login)

    respond_to do |format|
      if @skill.save
          format.html { redirect_to @skill, notice: t('.Success') } #'Values list version was successfully recalled.'
          format.json { render json: @skill, status: :created, location: @skill }
        else
          format.html { redirect_to @skill, notice: t('.Failure') } #'Values list vesion cannot be recalled.'
          format.json { render json: @skill.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_to_cart
    @template_skill = DefinedSkill.find(params[:id])
    print 'template skill '
    puts @template_skill.code

    if @template_skill.status.code == "ACCEPTED"
      # The counter variable is included in skills variables when the form is used in a record Show view
      iterations = (params[:counter] || params[:skill][:counter]).to_i
      print 'interations '
      puts iterations

      until iterations == 0
        @skill = @template_skill.becomes!(DeployedSkill).deep_clone include: [:translations]
        @skill.business_object_id = session[:cart_id]
        @skill.template_skill_id = @template_skill.id
        @skill.is_template = false
        # Remove DefinedSkill prefix from code
        list_id = ParametersList.where("code=?", 'LIST_OF_OBJECT_TYPES').take!
        prefix = Parameter.find_by("parameters_list_id=? AND code=?", list_id, @template_skill.class.name ).property
        #@skill.code = "#{@template_skill.code[prefix.length+1..-1]}-#{Time.now.strftime("%Y%m%d:%H%M%S")}-#{iterations}"
        @skill.code = "#{@template_skill.code[prefix.length+1..-1]}-#{iterations}"
        @skill.save
        @skill.errors.full_messages.each do |message|
          puts "Row #{@skill.code}: #{message}"
        end
        iterations -= 1
      end

      @business_object = DeployedObject.find(session[:cart_id])
      # 'Skill successfully added to business object'
      # redirect_to @business_object, notice: t('SkillAdded2BO')
      respond_to do |format|
        format.html { redirect_back fallback_location: @business_object, notice: @msg }
        format.js
      end
    end
  end

# Create a values_list from within the skill
  def create_values_list
    # Build values_list code to search
    list_id = ParametersList.where("code=?", 'LIST_OF_OBJECT_TYPES').take!
    prefix = Parameter.find_by("parameters_list_id=? AND code=?", list_id, 'ValuesList' ).property
    # Create a new list attached to this skill or attach the one with the same code
    if values_list = ValuesList.find_by_code("#{prefix}_#{@skill.code}")
      @skill.update_attributes(updated_by: current_login, values_list_id: values_list.id )
      redirect_to @skill, notice: t('SkillCanReceiveValues')
    else
      values_list = ValuesList.new(code: @skill.code, name: @skill.name, playground_id: @skill.playground_id, business_area_id: @skill.parent.parent.id,
         updated_by: current_login, created_by: current_login, owner_id: @skill.owner_id, major_version: 0, minor_version: 0, status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0)
      if values_list.save
        @skill.update_attributes(updated_by: current_login, values_list_id: values_list.id )
        list_of_languages.each do |locution|
          values_list.name_translations.build(field_name: 'name', language: locution.property, translation: @skill.code)
          values_list.description_translations.build(field_name: 'description', language: locution.property, translation: @skill.code)
        end
        values_list.save
        redirect_to @skill, notice: t('SkillCanReceiveValues')
      else
        redirect_to @skill, notice: t('SkillCannotReceiveValues')
      end
    end
  end

  def upload_values_list
    if @skill_values_list = ValuesList.find(@skill.values_list_id)
      redirect_to new_values_list_values_import_path(@skill_values_list)
    else
      redirect_to @skill, notice: t('SkillCannotReceiveValues')
    end
  end

  def remove_values_list
    respond_to do |format|
      if @skill.update_attributes(updated_by: current_login, values_list_id: nil)
        format.html { redirect_to @skill, notice: 'SkillSuccessfullyUpdated.' }
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @skill.errors, status: :unprocessable_entity }
      end
    end
  end

  ### private functions
    private

    ### Use callbacks to share common setup or constraints between actions.
      # Retrieve current skill
    def set_skill
      @skill = DefinedSkill.find(params[:id])
      if ValuesList.exists?(id: @skill.values_list_id)
        @child_values = @skill.values_list.values.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      end
      @child_skills = @skill.deployed_skills.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@skill)
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
      Translation.arel_table.alias('tr_external_descriptions')
    end

    def skills
      DefinedSkill.arel_table
    end

    def translated_skills
      skills.
      join(owners).on(skills[:responsible_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(skills[:id].eq(names[:document_id]).and(names[:document_type].eq("Skill")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(skills[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Skill")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(external_descriptions, Arel::Nodes::OuterJoin).on(skills[:id].eq(external_descriptions[:document_id]).and(external_descriptions[:document_type].eq("Skill")).and(external_descriptions[:language].eq(current_language).and(external_descriptions[:field_name].eq('external_description')))).
      join_sources
    end

    def index_fields
      [skills[:id], skills[:code], skills[:name], skills[:description], skills[:status_id], skills[:is_template], skills[:updated_by], skills[:updated_at], skills[:responsible_id], skills[:workflow_state], skills[:business_object_id], skills[:values_list_id], skills[:classification_id],
        owners[:name].as("responsible_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
        when not skills.is_active then '0'
        when skills.is_active and skills.is_finalised then '1'
        else '2'
          end").as("calculated_status")]
    end

    def order_by
      [skills[:created_at].asc]
    end

  ### strong parameters
  def defined_skill_params
    params.require(:defined_skill).permit(:playground_id, :business_object_id, :template_skill_id, :code, :name, :status_id, :description, :tr_name, :tr_description,
      :skill_type_id, :skill_size, :skill_min_size, :skill_precision, :skill_unit_id, :skill_role_id, :skill_aggregation_id, :values_list_id,
      :is_mandatory, :is_array, :is_pk, :is_ak, :is_published, :sensitivity_id, :regex_pattern, :source_type_id, :anything,
      :external_description, :is_pairing_key, :min_value, :max_value, :has_hierarchical_values, :_destroy, :id, :counter,  :id, :classification_id,
      :valid_from, :valid_to, :organisation_id, :responsible_id, :deputy_id,
      :uuid,
        name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        external_description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
      annotations_attributes: [:playground_id, :value_id, :annotation_type_id,  :uri, :code, :name, :id, :_destroy,
        description_translations_attributes: [:id, :field_name, :language, :translation, :_destroy]])
  end

  def evaluate_completion
    @completion_status = Array.new
    # translations
    @completion_status[0] = (1 - Translation.where("document_type = 'Skill' and document_id = ? and field_name = 'name' and translation = '' ", @skill.id).count.to_f / list_of_languages.length) * 100.00
    # values_list reference
    @completion_status[1] = (ValuesList.find(@skill.values_list_id).is_finalised ? 100 : 0) if ValuesList.exists?(id: @skill.values_list_id)
    # linked variables
    @completion_status[2] = nil
    # responsibilities
    @completion_status[3] = ((@skill.organisation_id != 0 ? 1 : 0) + (@skill.responsible_id != 0 ? 1 : 0) + (@skill.deputy_id != 0 ? 1 : 0)).to_f / 3 * 100.00
    # data types completion / consitency
    @completion_status[4] = ((@skill.skill_type_id == options_for('data_types').find { |x| x["code"] == "CODE-LIST" }.id) ^ !(@skill.skill_size == 0 or @skill.skill_size.blank? )) ? 100 : 0
    # existence of Primary Key
    @completion_status[5] = nil
  end

end
