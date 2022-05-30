class LandscapesController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current landscape
  before_action :set_landscape, only: [:show, :edit, :update, :destroy]

# Create the list statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /landscapes
  # GET /landscapes.json
  def index
    @landscapes = Landscape.joins(translated_landscapes).
                            pgnd(current_playground).
                            visible.
                            where("landscapes.owner_id = ? or ? is null", params[:owner], params[:owner]).
                            select(index_fields).
                            order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @landscapes }
    end
  end

  # GET /landscapes/1
  # GET /landscapes/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /landscapes/new
  # GET /landscapes/new.json
  def new
    @playground = Playground.find(params[:playground_id])
    @landscape = Landscape.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @landscape.name_translations.build(field_name: 'name', language: locution.property)
      @landscape.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /landscapes/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@landscape)
  end

  # POST /landscapes
  # POST /landscapes.json
  def create
    @playground = Playground.find(params[:playground_id])
    @landscape = @playground.landscapes.build(landscape_params)
    metadata_setup(@landscape)

    respond_to do |format|
      if @landscape.save
        format.html { redirect_to @landscape, notice: t('LSCreated') } #'Landscape was successfully created.'
        format.json { render json: @landscape, status: :created, location: @landscape }
      else
        format.html { render action: "new" }
        format.json { render json: @landscape.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /landscapes/1
  # PUT /landscapes/1.json
  def update
    ### Retrieved by Callback function
    @landscape.updated_by = current_login

    respond_to do |format|
      if @landscape.update_attributes(landscape_params)
        format.html { redirect_to @landscape, notice: t('LSUpdated') } #'Landscape was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @landscape.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /landscapes/1
  # POST /landscapes/1.json
  def activate
    ### Retrieved by Callback function
    @landscape.set_as_active(current_login)

    respond_to do |format|
      if @landscape.save
          format.html { redirect_to @landscape, notice: t('LSRecalled') } #'Business landscape was successfully recalled.'
          format.json { render json: @landscape, status: :created, location: @landscape }
        else
          format.html { redirect_to @landscape, notice: t('LSRecalledKO') } #'Business landsacpe  cannot be recalled.'
          format.json { render json: @landscape.errors, status: :unprocessable_entity }
      end
    end
  end

# DELETE /landscapes/1
# DELETE /landscapes/1.json
def destroy
  @landscape.set_as_inactive(current_login)
  respond_to do |format|
    format.html { redirect_to landscapes_url, notice: t('LSDeleted') } #'Business landsacpe was successfully deleted.'
    format.json { head :no_content }
  end
end


### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current landscape
    def set_landscape
      @landscape= Landscape.pgnd(current_playground).includes(:owner, :status).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@landscape)
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

    def landscapes
      Landscape.arel_table
    end

    def translated_landscapes
      landscapes.
      join(owners).on(landscapes[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(landscapes[:id].eq(names[:document_id]).and(names[:document_type].eq("Landscape")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(landscapes[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Landscape")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [landscapes[:id], landscapes[:code], landscapes[:hierarchy], landscapes[:name], landscapes[:description], landscapes[:status_id], landscapes[:updated_by], landscapes[:updated_at], landscapes[:is_active], landscapes[:is_current], landscapes[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not landscapes.is_active then '0'
          when landscapes.is_active and landscapes.is_finalised then '1'
          else '2'
          end").as("calculated_status")]
    end

    def order_by
      [landscapes[:hierarchy].asc]
    end

  ### strong parameters
  def landscape_params
    params.require(:landscape).permit(:code, :name, :status_id, :description, :tr_name, :tr_description,
    name_translations_attributes:[:id, :field_name, :language, :translation],
    description_translations_attributes:[:id, :field_name, :language, :translation])
  end

end
