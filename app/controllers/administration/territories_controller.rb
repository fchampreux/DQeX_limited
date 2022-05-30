class Administration::TerritoriesController < AdministrationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current business flow
  before_action :set_territory, only: [:show, :edit, :update, :destroy]

# Create the list of statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /Territories
  # GET /Territories.json
  def index
    @territories = Territory.joins(translated_territories).
                              where("territories.owner_id = ? or ? is null", params[:owner], params[:owner]).
                              visible.
                              select(index_fields).
                              order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @territories }
      format.csv { send_data @territories.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /Territories/1
  # GET /Territories/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /Territories/new
  # GET /Territories/new.json
  def new
    @parent = Territory.find(params[:territory_id])
    @territory = Territory.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @territory.name_translations.build(field_name: 'name', language: locution.property)
      @territory.description_translations.build(field_name: 'description', language: locution.property)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @territory }
    end
  end

  # GET /Territories/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@territory)
  end

  # POST /Territories
  # POST /Territories.json
  def create
    @parent = Territory.find(params[:territory_id])
    @territory = @parent.child_territories.build(territory_params)
    metadata_setup(@territory)

    respond_to do |format|
      if @territory.save
        format.html { redirect_to [:administration, @territory], notice: t('TerCreated') } #'Territory was successfully created.'
        format.json { render json: @territory, status: :created, location: @territory }
      else
        format.html { render action: "new" }
        format.json { render json: @territory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /Territories/1
  # PUT /Territories/1.json
  def update
    ### Retrieved by Callback function
    @territory.updated_by = current_login

    respond_to do |format|
      if @territory.update_attributes(territory_params)
        format.html { redirect_to [:administration, @territory], notice: t('TerUpdated') } #'Territory was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @territory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Territories/1
  # DELETE /Territories/1.json
  def destroy
    ### Retrieved by Callback function
    @territory.destroy

    respond_to do |format|
      format.html { redirect_to administration_territories_url }
      format.json { head :no_content }
    end
  end

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business flow
    def set_territory
      @territory = Territory.pgnd(current_playground).includes(:owner, :status, :parent).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@territory)
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

    def territories
      Territory.arel_table
    end

    def translated_territories
      territories.
      join(owners).on(territories[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(territories[:id].eq(names[:document_id]).and(names[:document_type].eq("Territory")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(territories[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Territory")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [territories[:id], territories[:code], territories[:hierarchy], territories[:name], territories[:description], territories[:status_id], territories[:updated_by], territories[:updated_at], territories[:is_active], territories[:is_current], territories[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not territories.is_active then '0'
          else '1'
          end").as("calculated_status")]
    end

    def order_by
      [territories[:hierarchy].asc]
    end

    def set_breadcrumbs
      object = @territory
      way_back = [object]
      while  object.territory_level > 1 # stop when reaches highest level
        path = object.ancestor
        way_back << path
        object = path
      end
      puts way_back.reverse
      @breadcrumbs = way_back.reverse
    end

  ### strong parameters
  def territory_params
    params.require(:territory).permit(:code, :name, :description, :parent_id, :status_id, :tr_name, :tr_description,
    name_translations_attributes:[:id, :field_name, :language, :translation],
    description_translations_attributes:[:id, :field_name, :language, :translation])
  end

end
