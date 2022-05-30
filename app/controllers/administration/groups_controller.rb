class Administration::GroupsController < AdministrationController
  include TerritoriesHelper, OrganisationsHelper
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_group, only: [:show, :edit, :update, :destroy, :activate]

    # Initialise breadcrumbs for the resulting view
    #before_action :set_breadcrumbs, only: [:show, :edit, :update]

    # GET /groups
    # GET /groups.json
    def index
      @groups = Group.joins(translated_groups).
                      where("groups.owner_id = ? or ? is null", params[:owner], params[:owner]).
                      visible.
                      select(index_fields).
                      order(order_by)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @groups }
      end
    end

  # GET /groups/1
  # GET /groups/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /groups/new
  def new
    @group = Group.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @group.name_translations.build(field_name: 'name', language: locution.property)
      @group.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /groups/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@group)
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    metadata_setup(@group)

    respond_to do |format|
      if @group.save
        format.html { redirect_to [:administration, @group], notice: t('GroupCreated') } #'Group was successfully created.'
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    @group.updated_by = current_login

    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to [:administration, @group], notice: t('GroupUpdated') } #'Group was successfully updated.'
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /groups/1
  # POST /groups/1.json
  def activate
    ### Retrieved by Callback function
    @group.set_as_active(current_login)

    respond_to do |format|
      if @group.save
          format.html { redirect_to [:administration, @group], notice: t('GroupRecalled') } #'Business landsacpe was successfully recalled.'
          format.json { render json: @group, status: :created, location: @group }
        else
          format.html { redirect_to [:administration, @group], notice: t('GroupRecalledKO') } #'Business landsacpe  cannot be recalled.'
          format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.set_as_inactive(current_login)

    respond_to do |format|
      format.html { redirect_to administration_groups_url, notice: t('GroupDeleted') } #'Group was successfully destroyed.'
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = translation_for(@group.name_translations)
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

    def groups
      Group.arel_table
    end

    def organisations
      Organisation.arel_table
    end

    def organisations_name
      Translation.arel_table.alias('tr_organisations')
    end
    def territories
      Territory.arel_table
    end

    def territories_name
      Translation.arel_table.alias('tr_territories')
    end


    def translated_groups
      groups.
      join(owners).on(groups[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(groups[:id].eq(names[:document_id]).and(names[:document_type].eq("Group")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(groups[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Group")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(organisations).on(groups[:organisation_id].eq(organisations[:id])).
      join(organisations_name, Arel::Nodes::OuterJoin).on(organisations[:id].eq(organisations_name[:document_id]).and(organisations_name[:document_type].eq("Organisation")).and(organisations_name[:language].eq(current_language).and(organisations_name[:field_name].eq('name')))).
      join(territories).on(groups[:territory_id].eq(territories[:id])).
      join(territories_name, Arel::Nodes::OuterJoin).on(territories[:id].eq(territories_name[:document_id]).and(territories_name[:document_type].eq("Organisation")).and(territories_name[:language].eq(current_language).and(territories_name[:field_name].eq('name')))).
      join_sources
    end

    def index_fields
      [groups[:id], groups[:code], groups[:name], groups[:description], groups[:territory_id], groups[:organisation_id], groups[:status_id], groups[:updated_by], groups[:updated_at], groups[:is_active],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        organisations_name[:translation].as("organisations_name"),
        territories_name[:translation].as("territories_name"),
        Arel::Nodes::SqlLiteral.new("case
          when not groups.is_active then '0'
          else '1'
          end").as("calculated_status")]
    end

    def order_by
      [groups[:code].asc]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :description, :role, :territory_id, :organisation_id, :created_by, :updated_by, :code,
      name_translations_attributes:[:id, :field_name, :language, :translation],
      description_translations_attributes:[:id, :field_name, :language, :translation],
      :role_ids => []) #, :feature_ids => [])
    end
end
