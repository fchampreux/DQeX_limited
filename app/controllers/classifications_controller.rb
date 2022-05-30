class ClassificationsController < ApplicationController
# Check for active session
  before_action :authenticate_user!, except: [:extract]
  load_and_authorize_resource

# Retrieve current list
  before_action :set_classification, except: [:create, :new, :index, :extract, :get_classifications_option_list]

  before_action :evaluate_completion, only: [:show, :propose, :accept, :reject, :reopen]

  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

# Initialise drop downs optins (To turn into helper functions !!!)

  before_action :set_statuses_list, only: [:new, :edit, :update, :create]

  # GET /classification
  # GET /classification.json
  def index
    @classifications = Classification.joins(translated_classifications).
                                      pgnd(current_playground).
                                      visible.
                                      where("classifications.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                      select(index_fields).
                                      order(order_by)

      respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @classifications }
      format.csv { send_data @classifications.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def get_classifications_option_list
    if not params[:values_list_id].blank?
      @classifications = Classification.joins(:values_lists_classifications).where("values_list_id = ?", params[:values_list_id]).visible.select(:id, :code).distinct
    else
      @classifications = Classification.all.visible.select(:id, :code)
    end
    respond_to do |format|
      format.js
      format.json { render json: @classifications }
    end
  end

  # GET /classification
  # GET /classification.json
  def extract
    @classification = Classification.finalised.find(params[:id])
    @values = @classification.values_lists.values#.select(:code, :alternate_code, :name, :alias, :abbreviation, :description )

      respond_to do |format|
        format.json { render json: @values }
        format.csv { send_data @values.to_csv }
        format.api { render plain: @values.to_csv, content_type: 'text/plain' }
        format.xml { render xml: @values.as_json(only: [:code, :name], skip_types: false) }
      end
  end

  # GET /classification/1
  # GET /classification/1.json
  def show
    ### Retrieved by Callback function

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @classification.values }
      format.csv { send_data @classification.values.to_csv }
      format.api { render plain: @classification.values.to_csv }
      format.xlsx # uses specific template to render xml
    end

  end

  # GET /classification/new
  def new
    @business_area = BusinessArea.find(params[:business_area_id])
    @classification = Classification.new

    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @classification.name_translations.build(field_name: 'name', language: locution.property)
      @classification.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # POST /classifications/new_version
  def new_version # Make sure this is current version, otherwise quit and notify
    Classification.without_callback(:create, :before, :set_hierarchy) do
      @classification_version = @classification.deep_clone include: [:translations]
      @classification_version.set_as_current(current_login) # Toggle current version
      @classification_version.major_version = @classification.last_version.next
      @classification_version.minor_version = 0
      @classification_version.is_finalised = false
      metadata_setup(@classification_version) # User becomes owner of the new version

      # If save is successful, render the show view, other wise render error messages
      respond_to do |format|
        if @classification_version.save
=begin # Duplicate links when new version is created
          @classification.values_lists.each do |value| # Duplicate associated values too
            dup_value = value.deep_clone include: [:translations]
            dup_value.classification_id = @classification_version.id
            dup_value.save
          end
=end
          @classification = @classification_version # Continue working with values list
          format.html { redirect_to @classification, notice: t('.Success') } # 'Values list version was successfully created.'
          format.json { render json: @classification, status: :created, location: @classification }
        else
          @classification = @classification_version # Continue working with values list
          format.html { redirect_to @classification, notice: t('.Failure') } #'Values list vesion cannot be created.'
          format.json { render json: @classification.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  # GET /classification/1/edit
  def edit
    ### Retrieved by Callback function

    ### Finalised Values list cannot be modified
    if @classification.is_finalised
      redirect_to @classification, notice: t('.Failure') #'Finalised Values list cannot be modified'
    end

    check_translations(@classification)
    # It may be interesting to include this in a transaction in order to roll back new minor version creation if the user does not validate the update
    # Update or create new version:
    # If current user is different from the previous who updated the record, then create a new version.
    if @classification.updated_by != current_login and $Versionning
      Classification.without_callback(:create, :before, :set_hierarchy) do # avoid re-calculation of code and hierarchy
        @classification_version = @classification.deep_clone include: [:translations]
        @classification_version.set_as_current(current_login) # Toggle current version
        @classification_version.minor_version = @classification.last_minor_version.next
        if @classification_version.save
=begin # Duplicate links when new version is created
          @classification.values.each do |value| # Duplicate associated values too
            dup_value = value.deep_clone include: [:translations]
            dup_value.classification_id = @classification_version.id
            dup_value.save
          end
=end
        end
      end
      @classification = @classification_version # Continue working with values list
      @child_values = @classification.values_lists.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end

  end

  # POST /classifications/make_current
  def make_current # Make sure this is not current version, otherwise quit and notify
    Classification.without_callback(:create, :before, :set_hierarchy) do
      @classification.set_as_current(current_login) # Toggle current version
      @classification.updated_by = current_login

      respond_to do |format|
        if @classification.save
          format.html { redirect_to @classification, notice: t('.Success') } #'Values list version was successfully selected.'
          format.json { render json: @classification, status: :created, location: @classification }
        else
          format.html { redirect_to @classification, notice: t('.Failure') } #'Values list vesion cannot be selected.'
          format.json { render json: @classification.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /classifications/finalise # flags this version as finalised
  def finalise
    Classification.without_callback(:create, :before, :set_hierarchy) do
      @classification.set_as_finalised(current_login) # Toggle current version
      @classification.updated_by = current_login

      respond_to do |format|
        if @classification.save
          format.html { redirect_to @classification, notice: t('.Success') } #'Values list version was successfully finalised.'
          format.json { render json: @classification, status: :created, location: @classification }
        else
          format.html { redirect_to @classification, notice: t('.Failure') } #'Values list vesion cannot be finalised.'
          format.json { render json: @classification.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /classification
  # POST /classification.json
  def create
    @business_area = BusinessArea.find(params[:business_area_id])
    @classification = @business_area.classifications.build(classification_params)
    if params[:anything]
      @classification.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @classification.anything = nil
    end
    @classification.major_version = 0
    @classification.minor_version = 0
    @classification.status_id = statuses.find { |x| x["code"] == "NEW" }.id || 0
    metadata_setup(@classification)

    respond_to do |format|
      if @classification.save
        format.html { redirect_to @classification, notice: t('.Success') } #'List of values was successfully created.'
        format.json { render json: @classification, status: :created, location: @classification }
      else
        format.html { render action: 'new' }
        format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /classification/1
  # PATCH/PUT /classification/1.json
  def update
    ### Retrieved by Callback function
    if params[:anything]
      @classification.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @classification.anything = nil
    end

    respond_to do |format|
      if @classification.update(classification_params)
        format.html { redirect_to @classification, notice: t('.Success') } #'Values list was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /classifications/1
  # POST /classifications/1.json
  def activate
    ### Retrieved by Callback function
    @classification.set_as_active(current_login)

    respond_to do |format|
      if @classification.save
          format.html { redirect_to @classification, notice: t('.Success') } #'Values list version was successfully recalled.'
          format.json { render json: @classification, status: :created, location: @classification }
        else
          format.html { redirect_to @classification, notice: t('.Failure') } #'Values list vesion cannot be recalled.'
          format.json { render json: @classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /classification/1
  # DELETE /classification/1.json
  def destroy
    ### Retrieved by Callback function
    @classification.set_as_inactive(current_login)
    respond_to do |format|
      format.html { redirect_to classifications_url, notice: t('.Success') } #'Values list was successfully deleted.'
      format.json { head :no_content }
    end
  end

  def propose
    puts "-------------------------------------------------------"
    puts "------------------ PROPOSED ---------------------------"
    puts "-------------------------------------------------------"
    @classification.submit!
    @classification.update_attribute(:status_id, statuses.find { |x| x["code"] == "SUBMITTED" }.id || 0 )
    @notification = Notification.create(playground_id: current_playground, description: t('.ClassificationSubmitted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @classification.parent.reviewer_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @classification.class.name, topic_id: @classification.id, deputy_id: @classification.parent.responsible_id, organisation_id: @classification.organisation_id, code: @classification.code, name: t('.ClassificationSubmitted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.Classification')} #{@classification.code} #{@classification.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.ClassificationSubmitted')}")
  end

  def accept
    puts "-------------------------------------------------------"
    puts "------------------ ACCEPTED ---------------------------"
    puts "-------------------------------------------------------"
    @classification.accept!
    @classification.update_attributes(:status_id => statuses.find { |x| x["code"] == "ACCEPTED" }.id || 0, :is_finalised => true)
    @notification = Notification.create(playground_id: current_playground, description: t('.ClassificationAccepted'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @classification.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @classification.class.name, topic_id: @classification.id, deputy_id: @classification.parent.responsible_id, organisation_id: @classification.organisation_id, code: @classification.code, name: t('.ClassificationAccepted'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('.Classification')} #{@classification.code} #{@classification.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('.ClassificationAccepted')}")
  end

  def reject
    # Reads the js answer
  end

  def reopen
    puts "-------------------------------------------------------"
    puts "------------------ REOPENED ---------------------------"
    puts "-------------------------------------------------------"
    @classification.reopen!
    @classification.update_attributes(:status_id => statuses.find { |x| x["code"] == "NEW" }.id || 0, :is_finalised => false)
    @notification = Notification.create(playground_id: current_playground, description: t('ClassificationReopened'), severity_id: options_for('rules_severity').find { |x| x["code"] == "INFO" }.id || 0,
    status_id: statuses.find { |x| x["code"] == "NEW" }.id || 0, expected_at: Time.now + 1.day, responsible_id: @classification.owner_id, owner_id: current_user.id, created_by: current_login, updated_by: current_login,
    topic_type: @classification.class.name, topic_id: @classification.id, deputy_id: @classification.parent.parent.responsible_id, organisation_id: @classification.organisation_id, code: @classification.code, name: t('ClassificationReopened'))
    # Create title and description for current language
    @notification.name_translations.create(field_name: 'name', language: current_language, translation: "#{t('Classification')} #{@classification.code} #{@classification.workflow_state}")
    @notification.description_translations.create(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t('ClassificationReopened')}")
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_classification
      @classification = Classification.find(params[:id])
      @values_lists_classifications = @classification.values_lists_classifications.order(:level)
      @cloned_classifications = Classification.where("hierarchy = ?", @classification.hierarchy )
      @defined_skills = @classification.defined_skills.visible.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      @deployed_skills = @classification.deployed_skills.visible.order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@classification)
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

    def classifications
      Classification.arel_table
    end

    def values
      Value.arel_table.alias('values')
    end

    def parent_values
      Value.arel_table.alias('parent')
    end

    def values_lists
      ValuesList.arel_table
    end

    def values_links
      ValuesToValues.arel_table
    end

    def classifications_lists
      ValuesListsClassification.arel_table
    end

    def translated_classifications
      classifications.
      join(owners).on(classifications[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(classifications[:id].eq(names[:document_id]).and(names[:document_type].eq("Classification")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(classifications[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Classification")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      #join(classifications_parent).on(classifications[:business_area_id].eq(classifications_parent[:id])).
      #join(classifications_owner).on(classifications[:owner_id].eq(classifications_owner[:id])).
      join_sources
    end

    def index_fields
      [classifications[:id], classifications[:code], classifications[:name], classifications[:description], classifications[:status_id], classifications[:updated_by], classifications[:updated_at], classifications[:is_active], classifications[:owner_id], classifications[:business_area_id], classifications[:playground_id],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
        when not classifications.is_active then '0'
        when classifications.is_active and classifications.is_finalised then '1'
        else '2'
          end").as("calculated_status")]
    end

    def order_by
      [classifications[:name].asc,classifications[:major_version], classifications[:minor_version]]
    end

    def joined_lists
      values_lists.
      join(classifications_lists).on(values_lists[:id].eq(classifications_lists[:values_list_id])).
      join(classifications).on(classifications[:id].eq(classifications_lists[:classification_id])).
      join(names, Arel::Nodes::OuterJoin).on(values_lists[:id].eq(names[:document_id]).and(names[:document_type].eq("ValuesList")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(values_lists[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("ValuesList")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def joined_lists_fields
      [classifications[:code], values_lists[:code], values_lists[:status_id], classifications_lists[:level],
           names[:translation].as("translated_name"),
           descriptions[:translation].as("translated_description") ]
    end

=begin

    def joined_lists
      classifications.
      join(classifications_lists).on(classifications[:id].eq(classifications_lists[:classification_id])).
      join(values_lists).on(values_lists[:id].eq(classifications_lists[:values_list_id])).
      join(names, Arel::Nodes::OuterJoin).on(values_lists[:id].eq(names[:document_id]).and(names[:document_type].eq("ValuesList")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(values_lists[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("ValuesList")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def joined_lists
      classifications.
      join(classifications_lists).on(classifications[:id].eq(classifications_lists[:classification_id])).
      join(values_lists).on(values_lists[:id].eq(classifications_lists[:values_list_id])).
      join(values).on(values[:values_list_id].eq(values_lists[:id])).
      join(values_link).on(values[:values_list_id].eq(values_lists[:id])).
      join(values).on(values[:values_list_id].eq(values_lists[:id])).
      join_sources
    end

    def detailed_fields
      [classifications[:code], values_lists[:code], ]
    end
=end
    # Never trust values from the scary internet, only allow the white list through.
    # 3 level deep nested attributes are delcared here:
    # classification -> name_translations
    #             -> description_translations
    #             -> Values  -> name_translations
    #                        -> description_translations
    #
    def classification_params
      params.require(:classification).permit(:name, :description, :code, :is_hierarchical, :max_levels, :new_version_remark, :status_id, :anything,
        :organisation_id, :responsible_id, :deputy_id, :active_from, :active_to, :tag_list, :reviewed_by, :reviewed_at, :approved_by, :approved_at,
          name_translations_attributes:[:id, :field_name, :language, :translation,
          :uuid, :_destroy],
          description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
          values_lists_classifications_attributes:[:id, :playground_id, :values_list_id, :description, :level, :filter, :type_id, :_destroy, :anything],
        annotations_attributes: [:playground_id, :value_id, :annotation_type_id,  :uri, :code, :name, :id, :_destroy,
          description_translations_attributes: [:id, :field_name, :language, :translation, :_destroy]])
    end

    def evaluate_completion
      @completion_status = Array.new
      # translations
      @completion_status[0] = (1 - Translation.where("document_type = 'Classification' and document_id = ? and field_name = 'name' and translation = '' ", @classification.id).count.to_f / list_of_languages.length) * 100.00
      # values_list reference
      #@completion_status[1] = (@classification.values_lists.map { |r| r.is_finalised }.reduce(true) { |result, flag| result && flag } ) ? 100 : 0
      @completion_status[1] = @classification.values_lists.any? ? (@classification.values_lists.map { |r| r.is_finalised ? 1.0 : 0.0 }.reduce(:+) / @classification.values_lists.count) * 100 : 0
      # linked variables
      @completion_status[2] = nil
      # responsibilities
      @completion_status[3] = ((@classification.organisation_id != 0 ? 1 : 0) + (@classification.responsible_id != 0 ? 1 : 0) + (@classification.deputy_id != 0 ? 1 : 0)).to_f / 3 * 100.00
      # data types completion / consitency
      @completion_status[4] = nil
      # existence of Primary Key
      @completion_status[5] = nil
    end
end
