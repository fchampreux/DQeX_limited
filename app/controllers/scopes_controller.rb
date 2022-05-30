class ScopesController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current business area
  before_action :set_scope, only: [:show, :edit, :update, :destroy, :activate, :finalise, :make_current]

# Create the list statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /scopes
  # GET /scopes.json
  def index
    @scopes = Scope.joins(translated_scopes).
                    pgnd(current_playground).
                    visible.
                    where("scopes.owner_id = ? or ? is null", params[:owner], params[:owner]).
                    select(index_fields).
                    order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @scopes }
    end
  end
  # GET /scopes/1
  # GET /scopes/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /scopes/new
  # GET /scopes/new.json
  def new
    @business_object = BusinessObject.find(params[:business_object_id])
    @scope = Scope.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @scope.name_translations.build(field_name: 'name', language: locution.property)
      @scope.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # POST /business_scopes/new_version
  def new_version # Make sure this is current version, otherwise quit and notify
    Scope.without_callback(:create, :before, :set_hierarchy) do
      @scope_version = @scope.dup
      @scope_version.set_as_current # Toggle current version
      @scope_version.major_version = @scope.last_version.next
      @scope_version.minor_version = 0
      metadata_setup(@scope_version) # User becomes owner of the new version
      @scope.translations.each do |version| # Duplicate associated translations too
        @scope_version.translations.build({language: version.language, translation: version.translation, field_name: version.field_name})
      end

      respond_to do |format|
        if @scope_version.save
          format.html { redirect_to @scope_version, notice: t('ScCreated') } #'Scope version was successfully created.'
          format.json { render json: @scope_version, status: :created, location: @scope_version }
        else
          format.html { redirect_to @scope, notice: t('ScCreatedKO') } #'Scope vesion cannot be created.'
          format.json { render json: @scope_version.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /business_scopes/make_current # make this version the current version
  def make_current # Make sure this is not current version, otherwise quit and notify
    Scope.without_callback(:create, :before, :set_hierarchy) do
      @scope.set_as_current(current_login) # Toggle current version

      respond_to do |format| # redundant save not needed as action already updates the record
        if @scope.save
          format.html { redirect_to @scope, notice: t('ScSelected') } # 'Scope version was successfully selected.'
          format.json { render json: @scope, status: :created, location: @scope }
        else
          format.html { redirect_to @scope, notice: t('ScSelectedKO') } # 'Scope vesion cannot be selected.'
          format.json { render json: @scope.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /business_scopes/finalise # flgs this version as finalised
  def finalise # Make sure this is not current version, otherwise quit and notify
    Scope.without_callback(:create, :before, :set_hierarchy) do
      @scope.set_as_finalised(current_login) # Toggle current version

      respond_to do |format| # redundant save not needed as action already updates the record
        if @scope.save
          format.html { redirect_to @scope, notice: t('ScFinalised') } #'Scope version was successfully finalised.'
          format.json { render json: @scope, status: :created, location: @scope }
        else
          format.html { redirect_to @scope, notice: t('ScFinalisedKO') } #'Scope vesion cannot be finalised.'
          format.json { render json: @scope.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  # GET /scopes/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@scope)
  end

  # POST /scopes
  # POST /scopes.json
  def create
    @business_object = BusinessObject.find(params[:business_object_id])
    @scope = @business_object.scopes.build(scope_params)
    if scope_params.has_key?(:uploaded_file)
      @scope.resource_file = upload_file
    end
    metadata_setup(@scope)

    respond_to do |format|
      if @scope.save
        format.html { redirect_to @scope, notice: t('ScCreated') } # 'Scope was successfully created.'
        format.json { render json: @scope, status: :created, location: @scope }
      else
        format.html { render action: "new" }
        format.json { render json: @scope.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /scopes/1
  # PUT /scopes/1.json
  def update
    ### Retrieved by Callback function
    @scope.updated_by = current_login
    if scope_params.has_key?(:uploaded_file)
      @scope.resource_file = upload_file
    end

    respond_to do |format|
      if @scope.update_attributes(scope_params)
        format.html { redirect_to @scope, notice: t('ScUpdated') } #'Scope was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @scope.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /scopes/1
  # POST /scopes/1.json
  def activate
    ### Retrieved by Callback function
    @scope.set_as_active(current_login)

    respond_to do |format|
      if @scope.save
          format.html { redirect_to @scope, notice: t('ScRecalled') } #'Scope version was successfully recalled.'
          format.json { render json: @scope, status: :created, location: @scope }
        else
          format.html { redirect_to @scope, notice: t('ScRecalledKO') } #'Scope vesion cannot be recalled.'
          format.json { render json: @scope.errors, status: :unprocessable_entity }
      end
    end
  end


# DELETE /scopes/1
# DELETE /scopes/1.json
def destroy
  @scope.set_as_inactive(current_login)
  respond_to do |format|
    format.html { redirect_to scopes_url, notice: t('ScDeleted') } #'Scope was successfully deleted.'
    format.json { head :no_content }
  end
end


### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current scope
    def set_scope
      @scope = Scope.pgnd(current_playground).includes(:owner, :status).find(params[:id])
      @cloned_scopes = Scope.where("hierarchy = ?", @scope.hierarchy )
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@scope)
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

    def scopes
      Scope.arel_table
    end

    def translated_scopes
      scopes.
      join(owners).on(scopes[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(scopes[:id].eq(names[:document_id]).and(names[:document_type].eq("Scope")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(scopes[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Scope")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [scopes[:id], scopes[:code], scopes[:hierarchy], scopes[:name], scopes[:description], scopes[:status_id], scopes[:updated_by], scopes[:updated_at], scopes[:is_active], scopes[:is_current], scopes[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not scopes.is_active then '0'
          when scopes.is_active and scopes.is_finalised then '1'
          else '2'
          end").as("calculated_status")]
    end

    def order_by
      [scopes[:hierarchy].asc]
    end

  def upload_file
    puts '/////////////// File Upload ////////////////'
    source_file = scope_params[:uploaded_file]
    File.open(Rails.root.join('storage', source_file.original_filename), 'wb') do |file|
      file.write(source_file.read)
    end
    return source_file.original_filename
  end

  ### strong parameters
  def scope_params
    params.require(:scope).permit(:code, :name, :status_id, :is_validated, :description, :load_interface, :uploaded_file, :valid_from, :valid_to,
       :sql_query, :db_technology, :db_connection, :db_owner_schema, :structure_name, :resource_file, :tr_name, :tr_description,
    name_translations_attributes:[:id, :field_name, :language, :translation],
    description_translations_attributes:[:id, :field_name, :language, :translation])
  end


end
