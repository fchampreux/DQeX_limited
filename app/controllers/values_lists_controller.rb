class ValuesListsController < ApplicationController
# Check for active session
  before_action :authenticate_user!, except: [:extract]
  load_and_authorize_resource

# Retrieve current list
  before_action :set_values_list, except: [:create, :new, :index, :extract]
  before_action :evaluate_completion, only: [:show, :propose, :accept, :reject, :reopen]

  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

# Initialise drop downs optins (To turn into helper functions !!!)

  before_action :set_statuses_list, only: [:new, :edit, :update, :create]

  # GET /values_list
  # GET /values_list.json
  def index
    @values_lists = ValuesList.joins(translated_values_lists).
                                pgnd(current_playground).
                                visible.
                                where("values_lists.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                select(index_fields).
                                order(order_by)

      respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @values_lists }
      format.csv { send_data @values_lists.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /values_list
  # GET /values_list.json
  def extract
    @values_list = ValuesList.find(params[:id])
    @values = @values_list.values#.select(:code, :alternate_code, :name, :alias, :abbreviation, :description )

      respond_to do |format|
        format.json { render json: @values }
        format.csv { send_data @values.to_csv }
        format.api { render plain: @values.to_csv, content_type: 'text/plain' }
        format.xml { render xml: @values.as_json(only: [:code, :name], skip_types: false) }
      end
  end

  # GET /values_list/1
  # GET /values_list/1.json
  def show
    ### Retrieved by Callback function

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @values_list.values }
      format.csv { send_data @values_list.values.to_csv }
      format.api { render plain: @values_list.values.to_csv }
      format.xlsx {render xlsx: "show", filename: "#{@values_list.code}_values.xlsx", disposition: 'inline'}
    end

  end

  # GET /values_list/1/read_SDMX
  # Read and update values from a SDMX web service
  def read_SDMX
    if @values_list.resource_name&.match?("^(http|https)://")
      Rails.logger.info "--- Refresh values-list #{@values_list.code} from #{@values_list.resource_name}."
      resource = URI.open(@values_list.resource_name, proxy: false)
      document = Nokogiri::XML(resource)
      codes = document.xpath('//structure:CodeList[@isFinal="true"]/structure:Code')

      # Initialise counters
      @max_counter = codes.count
      @update_counter = 0
      @insert_counter = 0
      @annotation_update_counter = 0
      @annotation_insert_counter = 0

      # Read each code of the list
      codes.each do |index|
        index_code = index.xpath('@value').text
        if value = Value.find_by(values_list_id: @values_list.id,
                                code: index_code)
          Rails.logger.info "------ code: #{index_code} to update"
          @update_counter += 1
        else
          value = Value.new(playground_id: @values_list.playground_id,
                            values_list_id:  @values_list.id,
                            code: index_code)
          Rails.logger.info "------ code: #{index_code} to create"
          @insert_counter += 1
        end

        # Read translations
        list_of_languages.order(:property).each do |locution|
          content = index.xpath("structure:Description[@xml:lang='#{locution.code}']").text
          if name = Translation.find_by(document_type: 'Value',
                                        document_id: value.id,
                                        field_name: 'name',
                                        language: locution.property)
            name.update_attribute(:translation, content) unless name.translation == content
          else
            value.name_translations.build(field_name: 'name',
                                          language: locution.property,
                                          translation: content)
          end
          if description = Translation.find_by(document_type: 'Value',
                                              document_id: value.id,
                                              field_name: 'description',
                                              language: locution.property)
            description.update_attribute(:translation, content) unless description.translation == content
          else
            value.description_translations.build(field_name: 'description',
                                                language: locution.property,
                                                translation: content)
          end
        end

        # Read annotations
        Rails.logger.info "--------- search for code #{index_code} annotation"
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
          if annotation = Annotation.find_by(object_extra_type: 'Value',
                                            object_extra_id: value.id,
                                            annotation_type_id: note_type_id,
                                            name: note_title)
            annotation.update_attribute(:uri, note_uri) unless annotation.uri == note_uri
            @annotation_update_counter += 1
          else
            annotation = value.annotations.build(annotation_type_id: note_type_id,
                                                name: note_title,
                                                uri: note_uri,
                                                code: note_type,
                                                playground_id: value.playground_id)
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
          #byebug
        end
        value.save
        Rails.logger.info "------------ Value saved"
      end

      redirect_to @values_list, notice: "#{@insert_counter} #{t('values_lists.read_SDMX.ImportedValues')},
                                         #{@update_counter} #{t('values_lists.read_SDMX.UpdatedtedValues')},
                                         #{@max_counter} #{t('values_lists.read_SDMX.TotalValues')},
                                         #{@annotation_insert_counter} #{t('values_lists.read_SDMX.InsertedAnnotations')},
                                         #{@annotation_update_counter} #{t('values_lists.read_SDMX.UpdatedtedAnnotations')}."
    end
  end

  # GET /values_list/new
  def new
    @business_area = BusinessArea.find(params[:business_area_id])
    @values_list = ValuesList.new

    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @values_list.name_translations.build(field_name: 'name', language: locution.property)
      @values_list.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # POST /values_lists/new_version
  def new_version # Make sure this is current version, otherwise quit and notify
    ValuesList.without_callback(:create, :before, :set_hierarchy) do
      @values_list_version = @values_list.deep_clone include: [:translations]
      @values_list_version.set_as_current(current_login) # Toggle current version
      @values_list_version.major_version = @values_list.last_version.next
      @values_list_version.minor_version = 0
      @values_list_version.is_finalised = false
      metadata_setup(@values_list_version) # User becomes owner of the new version

      # If save is successful, render the show view, other wise render error messages
      respond_to do |format|
        if @values_list_version.save
          @values_list.values.each do |value| # Duplicate associated values too
            dup_value = value.deep_clone include: [:translations]
            dup_value.values_list_id = @values_list_version.id
            dup_value.save
          end
          @values_list = @values_list_version # Continue working with values list
          format.html { redirect_to @values_list, notice: t('.ValuesListCreated') } # 'Values list version was successfully created.'
          format.json { render json: @values_list, status: :created, location: @values_list }
        else
          @values_list = @values_list_version # Continue working with values list
          format.html { redirect_to @values_list, notice: t('.ValuesListCreatedKO') } #'Values list vesion cannot be created.'
          format.json { render json: @values_list.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  # GET /values_list/1/edit
  def edit
    ### Retrieved by Callback function

    ### Finalised Values list cannot be modified
    if @values_list.is_finalised
      redirect_to @values_list, notice: t('.FinalisedValuesListEditKO') #'Finalised Values list cannot be modified'
    end

    check_translations(@values_list)
    # It may be interesting to include this in a transaction in order to roll back new minor version creation if the user does not validate the update
    # Update or create new version:
    # If current user is different from the previous who updated the record, then create a new version.
    if @values_list.updated_by != current_login and $Versionning
      ValuesList.without_callback(:create, :before, :set_hierarchy) do # avoid re-calculation of code and hierarchy
        @values_list_version = @values_list.deep_clone include: [:translations]
        @values_list_version.set_as_current(current_login) # Toggle current version
        @values_list_version.minor_version = @values_list.last_minor_version.next
        if @values_list_version.save
          @values_list.values.each do |value| # Duplicate associated values too
            dup_value = value.deep_clone include: [:translations]
            dup_value.values_list_id = @values_list_version.id
            dup_value.save
          end
        end
      end
      @values_list = @values_list_version # Continue working with values list
      @child_values = @values_list.values.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end

  end

  # POST /values_lists/make_current
  def make_current # Make sure this is not current version, otherwise quit and notify
    ValuesList.without_callback(:create, :before, :set_hierarchy) do
      @values_list.set_as_current(current_login) # Toggle current version
      @values_list.updated_by = current_login

      respond_to do |format|
        if @values_list.save
          format.html { redirect_to @values_list, notice: t('.ValuesListSelected') } #'Values list version was successfully selected.'
          format.json { render json: @values_list, status: :created, location: @values_list }
        else
          format.html { redirect_to @values_list, notice: t('.ValuesListSelectedKO') } #'Values list vesion cannot be selected.'
          format.json { render json: @values_list.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /values_lists/finalise # flags this version as finalised
  def finalise
    ValuesList.without_callback(:create, :before, :set_hierarchy) do
      @values_list.set_as_finalised(current_login) # Toggle current version
      @values_list.updated_by = current_login

      respond_to do |format|
        if @values_list.save
          format.html { redirect_to @values_list, notice: t('.ValuesListFinalised') } #'Values list version was successfully finalised.'
          format.json { render json: @values_list, status: :created, location: @values_list }
        else
          format.html { redirect_to @values_list, notice: t('.ValuesListFinalisedKO') } #'Values list vesion cannot be finalised.'
          format.json { render json: @values_list.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /values_list
  # POST /values_list.json
  def create
    @business_area = BusinessArea.find(params[:business_area_id])
    @values_list = @business_area.values_lists.build(values_list_params)
    if params[:anything]
      @values_list.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @values_list.anything = nil
    end
    @values_list.major_version = 0
    @values_list.minor_version = 0
    @values_list.status_id = statuses.find { |x| x["code"] == "NEW" }.id || 0
    metadata_setup(@values_list)

    respond_to do |format|
      if @values_list.save
        format.html { redirect_to @values_list, notice: t('.ValuesListCreated') } #'List of values was successfully created.'
        format.json { render json: @values_list, status: :created, location: @values_list }
      else
        format.html { render action: 'new' }
        format.json { render json: @values_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /values_list/1
  # PATCH/PUT /values_list/1.json
  def update
    ### Retrieved by Callback function
    if params[:anything]
      @values_list.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @values_list.anything = nil
    end

    respond_to do |format|
      if @values_list.update(values_list_params)
        format.html { redirect_to @values_list, notice: t('.Success') } #'Values list was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @values_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /values_lists/1
  # POST /values_lists/1.json
  def activate
    ### Retrieved by Callback function
    @values_list.set_as_active(current_login)

    respond_to do |format|
      if @values_list.save
          format.html { redirect_to @values_list, notice: t('.ValuesListRecalled') } #'Values list version was successfully recalled.'
          format.json { render json: @values_list, status: :created, location: @values_list }
        else
          format.html { redirect_to @values_list, notice: t('.ValuesListRecalledKO') } #'Values list vesion cannot be recalled.'
          format.json { render json: @values_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /values_list/1
  # DELETE /values_list/1.json
  def destroy
    ### Retrieved by Callback function
    @values_list.set_as_inactive(current_login)
    respond_to do |format|
      format.html { redirect_to values_lists_url, notice: t('.ValuesListDeleted') } #'Values list was successfully deleted.'
      format.json { head :no_content }
    end
  end

  def propose
    puts "-------------------------------------------------------"
    puts "------------------ PROPOSED ---------------------------"
    puts "-------------------------------------------------------"
    @values_list.submit!
    @values_list.update_attribute(:status_id, statuses.find { |x| x["code"] == "SUBMITTED" }.id || 0 )
    @notification = Notification.create(playground_id: current_playground, description: t('.ValuesListSubmitted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @values_list.parent.reviewer_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @values_list.class.name, topic_id: @values_list.id, deputy_id: @values_list.parent.responsible_id, organisation_id: @values_list.organisation_id, code: @values_list.code, name: t('.ValuesListSubmitted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.ValuesList')} #{@values_list.code} #{@values_list.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.ValuesListSubmitted')}")
  end

  def accept
    puts "-------------------------------------------------------"
    puts "------------------ ACCEPTED ---------------------------"
    puts "-------------------------------------------------------"
    @values_list.accept!
    @values_list.update_attributes(:status_id => statuses.find { |x| x["code"] == "ACCEPTED" }.id || 0, :is_finalised => true)
    @notification = Notification.create(playground_id: current_playground, description: t('.ValuesListAccepted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @values_list.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @values_list.class.name, topic_id: @values_list.id, deputy_id: @values_list.parent.responsible_id, organisation_id: @values_list.organisation_id, code: @values_list.code, name: t('.ValuesListAccepted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.ValuesList')} #{@values_list.code} #{@values_list.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.ValuesListAccepted')}")
  end

  def reject
    # Reads the js answer
  end

  def reopen
    puts "-------------------------------------------------------"
    puts "------------------ REOPENED ---------------------------"
    puts "-------------------------------------------------------"
    @values_list.reopen!
    @values_list.update_attributes(:status_id => statuses.find { |x| x["code"] == "NEW" }.id || 0, :is_finalised => false)
    @notification = Notification.create(playground_id: current_playground, description: t('ValuesListReopened'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @values_list.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @values_list.class.name, topic_id: @values_list.id, deputy_id: @values_list.parent.parent.responsible_id, organisation_id: @values_list.organisation_id, code: @values_list.code, name: t('ValuesListReopened'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('Skill')} #{@values_list.code} #{@values_list.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('ValuesListReopened')}")
  end

  # GET children from values_list, including translations for child index
  def get_children
    puts '###################### Params ######################'
    print 'id : '
    puts params[:id]
    print 'classification id : '
    puts params[:classification_id]
    print 'filter : '
    puts params[:filter]
    @values = @values_list.values.includes(:name_translations).where("#{params[:filter]}").order(:code)
    @values.each do |child|
      child.classification_id = params[:classification_id]
    end

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @values }
      format.js # uses specific template to handle js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_values_list
      @values_list = ValuesList.pgnd(current_playground).find(params[:id])
      @child_values = @values_list.values.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      @cloned_values_lists = ValuesList.where("hierarchy = ?", @values_list.hierarchy )
      @defined_skills = @values_list.defined_skills.visible.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      @deployed_skills = @values_list.deployed_skills.visible.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@values_list)
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

    def values_lists
      ValuesList.arel_table
    end

    def list_types
      Parameter.arel_table
    end

    def translated_values_lists
      values_lists.
      join(owners).on(values_lists[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(values_lists[:id].eq(names[:document_id]).and(names[:document_type].eq("ValuesList")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(values_lists[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("ValuesList")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(list_types).on(values_lists[:list_type_id].eq(list_types[:id])).
      join_sources
    end

    def index_fields
      [values_lists[:id], values_lists[:code], values_lists[:name], values_lists[:description], values_lists[:status_id], values_lists[:updated_by], values_lists[:updated_at], values_lists[:is_active], values_lists[:owner_id],
      values_lists[:business_area_id], values_lists[:playground_id], list_types[:property].as("object_type"),
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not values_lists.is_active then '0'
          when values_lists.is_active and values_lists.is_finalised then '1'
          else '2'
          end").as("calculated_status")]
    end

    def order_by
      [values_lists[:name].asc,values_lists[:major_version], values_lists[:minor_version]]
    end

    # Never trust values from the scary internet, only allow the white list through.
    # 3 level deep nested attributes are delcared here:
    # Values_list -> name_translations
    #             -> description_translations
    #             -> Values  -> name_translations
    #                        -> description_translations
    #
    def values_list_params
      params.require(:values_list).permit(:name, :description, :code, :is_hierarchical, :max_levels, :resource_name, :new_version_remark, :status_id,
        :anything, :organisation_id, :responsible_id, :deputy_id, :active_from, :active_to, :list_type_id, :code_type_id, :code_max_length,
        :reviewed_by, :reviewed_at, :approved_by, :approved_at,
        :uuid,
          values_attributes: [:name, :description, :code, :id, :parent_code, :_destroy,
            name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
            description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy]],
          name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
          description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
          annotations_attributes: [:playground_id, :value_id, :annotation_type_id,  :uri, :code, :name, :id, :_destroy,
            description_translations_attributes: [:id, :field_name, :language, :translation, :_destroy]])
    end

    def evaluate_completion
      @completion_status = Array.new
      # translations
      @completion_status[0] = (1 - Translation.where("document_type = 'ValuesList' and document_id = ? and field_name = 'name' and translation = '' ", @values_list.id).count.to_f / list_of_languages.length) * 100.00
      # values_list reference
      @completion_status[1] = nil
      # linked variables
      @completion_status[2] = nil
      # responsibilities
      @completion_status[3] = ((@values_list.organisation_id != 0 ? 1 : 0) + (@values_list.responsible_id != 0 ? 1 : 0) + (@values_list.deputy_id != 0 ? 1 : 0)).to_f / 3 * 100.00
      # data types completion / consitency
      @completion_status[4] = nil
      # existence of Primary Key
      @completion_status[5] = nil
    end

end
