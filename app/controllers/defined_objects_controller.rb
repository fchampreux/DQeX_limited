class DefinedObjectsController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current business process
  before_action :set_business_object, except: [:create, :new, :index, :index_used, :derive]

# Create the list of statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]

  # Create the list of data types to be used in the skills rows
  before_action :set_data_types_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /business_objects
  # GET /business_objects.json
  # Returns only Defined (templates) and Visible (active) business objects
  def index
    @business_objects = DefinedObject.joins(translated_objects).
                                      pgnd(current_playground).
                                      where("business_objects.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                      visible.
                                      select(index_fields).order(order_by)

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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @business_object.defined_skills }
      format.csv { send_data @business_object.defined_skills.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /defeined_object/1/read_SDMX
  # Read and update variables from a SDMX web service
  def read_SDMX
    if @business_object.resource_name&.match?("^(http|https)://")
      Rails.logger.info "--- Refresh defined_object #{@business_object.code} from #{@business_object.resource_name}."
      resource = URI.open(@business_object.resource_name, proxy: false)
      document = Nokogiri::XML(resource)
      concepts = document.xpath('//structure:ConceptScheme[@isFinal="true"]/structure:Concept')

      # Initialise counters
      @max_counter = concepts.count
      @update_counter = 0
      @insert_counter = 0
      @annotation_update_counter = 0
      @annotation_insert_counter = 0

      # Read each concept of the list
      concepts.each do |index|
        puts "--- index ---"
        puts index.xpath('@id')
        # Ignore concepts that are not in the list
        next if !@business_object.resource_list.include? index.xpath('@id').text

        # Create the concept if it does not exist
        # SDMX attributes
        puts "---Concept identifier"
        puts id_concept = index.xpath('@id').text
        puts "--- Datatype"
        concept_format = index.xpath('structure:TextFormat')
        puts concept_type = concept_format.xpath('@textType').text.upcase
        puts "--- Look-up"
        puts concept_look_up = index.xpath('@coreRepresentation').text
        puts code_list_id = ValuesList.find_by_code(concept_look_up)&.id
        if concept = Skill.find_by(business_object_id: @business_object.id,
                                code: "DV_#{id_concept}")
          Rails.logger.info "------ variable: #{id_concept} to update"
          concept.is_template = true,
          concept.skill_type_id = options_for('data_types').find { |x| x["code"] == concept_type }&.id || 0
          concept.created_by = current_user.user_name
          concept.updated_by = current_user.user_name
          concept.owner_id = current_user.id
          concept.values_list_id = code_list_id
          puts"--- updated skill ---"
          puts concept.attributes
          @update_counter += 1
        else
          Rails.logger.info "------ variable: #{id_concept} to create"

          concept = DefinedSkill.new(playground_id: @business_object.playground_id,
                              business_object_id:  @business_object.id,
                              code: id_concept,
                              is_template: true,
                              skill_type_id: options_for('data_types').find { |x| x["code"] == concept_type }&.id || 0,
                              created_by: current_user.user_name,
                              updated_by: current_user.user_name,
                              owner_id: current_user.id,
                              values_list_id: code_list_id
                          )
          puts"--- new skill ---"
          puts concept.attributes
          @insert_counter += 1
        end

        # Read translations
        list_of_languages.order(:property).each do |locution|
          content = index.xpath("structure:Description[@xml:lang='#{locution.code}']").text
          if name = Translation.find_by(document_type: 'Skill',
                                        document_id: concept.id,
                                        field_name: 'name',
                                        language: locution.property)
            name.update_attribute(:translation, content) unless name.translation == content
          else
            concept.name_translations.build(field_name: 'name',
                                          language: locution.property,
                                          translation: content)
          end
          if description = Translation.find_by(document_type: 'Skill',
                                              document_id: concept.id,
                                              field_name: 'description',
                                              language: locution.property)
            description.update_attribute(:translation, content) unless description.translation == content
          else
            concept.description_translations.build(field_name: 'description',
                                                language: locution.property,
                                                translation: content)
          end
        end

        # Read annotations
        Rails.logger.info "--------- search for code #{id_concept} annotation"
        index.xpath('structure:Annotations/common:Annotation').each do |note|
          puts " -------------- Annotations -----------------"
          puts note_title = note.xpath('common:AnnotationTitle').text
          puts note_type = note.xpath('common:AnnotationType').text || 'OTHER'
          # Create annotation type if it does not exists
          if parameter = options_for('annotation_types').find { |x| x["code"] == note_type.upcase }
            puts "--- Found parameter:"
            puts parameter
            #note_type_id = parameter.id
          else
            Rails.logger.info "------------ annotation requires TYPE creation: #{note_type}"
            annotations_types = ParametersList.where("code=?", "LIST_OF_ANNOTATION_TYPES").take!
            parameter = Parameter.new(playground_id: 0,
                                      parameters_list_id: annotations_types.id,
                                      code: note_type.upcase,
                                      property: note_type,
                                      active_from: Time.now,
                                      active_to: Time.now + 10.years,
                                      sort_code: note_type.upcase )
            puts "--- Creating parameter:"
            puts parameter
            list_of_languages.order(:property).each do |locution|
              parameter.name_translations.build(field_name: 'name',
                                                language: locution.property,
                                                translation: note_type)
            end
            parameter.save!
            Rails.logger.info "------------ Annotation type saved"
            Rails.logger.info "------------ #{parameter}"
            puts "--- Created parameter:"
            puts parameter
          end
          puts note_type_id = parameter.id
          puts note_uri = note.xpath('common:AnnotationURI').text
          note_text = Hash.new
          list_of_languages.order(:property).each do |locution|
            note_text[locution] = note.xpath("common:AnnotationText[@xml:lang='#{locution.code}']").text
          end
          puts note_text
          if annotation = Annotation.find_by(object_extra_type: 'Skill',
                                            object_extra_id: concept.id,
                                            annotation_type_id: note_type_id,
                                            name: note_title)
            annotation.update_attribute(:uri, note_uri) unless annotation.uri == note_uri
            @annotation_update_counter += 1
          else
            annotation = concept.annotations.build(annotation_type_id: note_type_id,
                                                name: note_title,
                                                uri: note_uri,
                                                code: note_type,
                                                playground_id: concept.playground_id)
            @annotation_insert_counter += 1
          end
          # Read translations
          list_of_languages.order(:property).each do |locution|
            if description = Translation.find_by(document_type: 'Annotation',
                                          document_id: annotation.id,
                                          field_name: 'description',
                                          language: locution.property)
              description.update_attribute(:translation, note_text[locution]) unless description.translation == note_text[locution]
            else
              annotation.description_translations.build(field_name: 'description',
                                            language: locution.property,
                                            translation: note_text[locution])
            end
          end
        end

        concept.save
        Rails.logger.info "------------ Concept saved"

      end

    end
    redirect_to @business_object, notice: "#{@insert_counter} #{t('defined_objects.read_SDMX.ImportedConcepts')},
                                           #{@update_counter} #{t('defined_objects.read_SDMX.UpdatedtedConcepts')},
                                           #{@max_counter} #{t('defined_objects.read_SDMX.TotalConcepts')},
                                           #{@annotation_insert_counter} #{t('defined_objects.read_SDMX.InsertedAnnotations')},
                                           #{@annotation_update_counter} #{t('defined_objects.read_SDMX.UpdatedtedAnnotations')}."

  end

  # GET /business_objects/new
  # GET /business_objects/new.json
  def new
    @parent = params[:parent_class].constantize.find(params[:parent_id])
    @business_object = @parent.defined_objects.build(status_id: (statuses.find { |x| x["code"] == "NEW" }.id || 0),
                                                    is_template: @parent.class == BusinessArea ? true : false,
                                                    responsible_id: @parent.responsible_id,
                                                    deputy_id: @parent.deputy_id,
                                                    organisation_id: @parent.parent.organisation_id)
    @child_skills = @business_object.defined_skills.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)

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

  # POST /business_objects/make_current
  def make_current # Make sure this is not current version, otherwise quit and notify
    DefinedObject.without_callback(:create, :before, :set_hierarchy) do
      @business_object.set_as_current(current_login) # Toggle current version
      @business_object.updated_by = current_login

      respond_to do |format|
        if @business_object.save
          format.html { redirect_to @business_object, notice: t('BovSelected') } #'Business object version was successfully selected.'
          format.json { render json: @business_object, status: :created, location: @business_object }
        else
          format.html { redirect_to @business_object, notice: t('BovSelectedKO') } #'Business object vesion cannot be selected.'
          format.json { render json: @business_object.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /business_objects/finalise # flags this version as finalised
  def finalise
    DefinedObject.without_callback(:create, :before, :set_hierarchy) do
      @business_object.set_as_finalised(current_login) # Toggle current version
      @business_object.updated_by = current_login

      respond_to do |format|
        if @business_object.save
          format.html { redirect_to @business_object, notice: t('BovFinalised') } #'Business object version was successfully finalised.'
          format.json { render json: @business_object, status: :created, location: @business_object }
        else
          format.html { redirect_to @business_object, notice: t('BovFinalisedKO') } #'Business object vesion cannot be finalised.'
          format.json { render json: @business_object.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /business_objects/new_version
  def new_version # Make sure this is current version, otherwise quit and notify
    DefinedObject.without_callback(:create, :before, :set_hierarchy) do
      @business_object_version = @business_object.deep_clone include: [:translations]
      @business_object_version.set_as_current(current_login) # Toggle current version
      @business_object_version.major_version = @business_object.last_version.next
      @business_object_version.minor_version = 0
      @business_object_version.is_finalised = false
      metadata_setup(@business_object_version) # User becomes owner of the new version

      # If save is successful, render the show view, other wise render error messages
      respond_to do |format|
        if @business_object_version.save
          @business_object.skills.each do |skill| # Duplicate associated skills too
            dup_skill = skill.deep_clone include: [:translations]
            dup_skill.business_object_id = @business_object_version.id
            dup_skill.save
          end
          @business_object = @business_object_version # Continue working with business object
          format.html { redirect_to @business_object, notice: t('BovCreated') } #'Business object version was successfully created.'
          format.json { render json: @business_object, status: :created, location: @business_object }
        else
          @business_object = @business_object_version # Continue working with business object
          format.html { redirect_to @business_object, notice: t('BovCreatedKO') } #'Business object vesion cannot be created.'
          format.json { render json: @business_object.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /business_objects/1/edit
  def edit
    ### Retrieved by Callback

    ### Finalised business object cannot be modified
    if @business_object.is_finalised
      redirect_to @business_object, notice: t('FinBOModifKO')  #'Finalised Business Object cannot be modified'
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
          @business_object.defined_skills.each do |skill| # Duplicate associated skills too
            dup_skill = skill.deep_clone include: [:translations]
            dup_skill.business_object_id = @business_object_version.id
            dup_skill.save
          end
        end
      end
      @business_object = @business_object_version # Continue working with business object
      @child_skills = @business_object.defined_skills.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end

  end

  # POST /business_objects
  # POST /business_objects.json
  def create
    @parent = defined_object_params[:parent_type].constantize.find(defined_object_params[:parent_id])
    @business_object = @parent.defined_objects.build(defined_object_params)
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
      if @business_object.update_attributes(defined_object_params)
        format.html { redirect_to @business_object, notice: t('BOUpdated') } # 'Business object was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_object.errors, status: :unprocessable_entity }
      end
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

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business object
    def set_business_object
      # Is it relevant to generate the child skills here and in other places in the contoller?
      @business_object = DefinedObject.pgnd(current_playground).includes(:owner, :status).find(params[:id])
      @child_skills = @business_object.defined_skills.visible.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      @cloned_business_objects = DefinedObject.where("hierarchy = ?", @business_object.hierarchy )
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
      DefinedObject.arel_table
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
      [objects[:hierarchy].asc,objects[:major_version], objects[:minor_version]]
    end

  ### strong parameters
  def defined_object_params
    params.require(:defined_object).permit(:code,
                                          :name,
                                          :status_id,
                                          :pcf_index,
                                          :pcf_reference,
                                          :description,
                                          :granularity_id,
                                          :period,
                                          :ogd_id,
                                          :tr_name,
                                          :tr_description,
                                          :parent_type,
                                          :parent_id,
                                          :parent_class,
                                          :active_from,
                                          :active_to,
                                          :is_template,
                                          :organisation_id,
                                          :responsible_id,
                                          :deputy_id,
                                          :external_description,
                                          :reviewed_by,
                                          :reviewed_at,
                                          :approved_by,
                                          :approved_at,
                                          :resource_name,
                                          :resource_list,
                                          skills_attributes:[:code,
                                                            :name,
                                                            :description,
                                                            :is_pk,
                                                            :is_published,
                                                            :skill_type_id,
                                                            :skill_size,
                                                            :skill_precision,
                                                            :_destroy,
                                                            :id,
                                                            name_translations_attributes:[:id,
                                                                                          :field_name,
                                                                                          :language,
                                                                                          :translation,
                                                                                          :_destroy],
                                                            description_translations_attributes:[:id,
                                                                                                :field_name,
                                                                                                :language,
                                                                                                :translation,
                                                                                                :_destroy]],
                                          name_translations_attributes:[:id,
                                                                        :field_name,
                                                                        :language,
                                                                        :translation,
                                                                        :_destroy],
                                          description_translations_attributes:[:id,
                                                                              :field_name,
                                                                              :language,
                                                                              :translation, :_destroy],
                                          :participant_ids => [])
  end

end
