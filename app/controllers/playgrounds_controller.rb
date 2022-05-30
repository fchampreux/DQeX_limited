class PlaygroundsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current playground
  before_action :set_playground, only: [:show, :edit, :update, :destroy, :activate, :set_as_current, :business_areas]

# Create the list statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /playgrounds
  # GET /playgrounds.json
  def index
    @playgrounds = Playground.joins(translated_playgrounds).
                              where.not(id: 0).
                              visible.
                              where("playgrounds.owner_id = ? or ? is null", params[:owner], params[:owner]).
                              select(index_fields).
                              order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @playgrounds }
      format.csv { send_data @playgrounds.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /playgrounds/1
  # GET /playgrounds/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /playgrounds/new
  # GET /playgrounds/new.json
  def new
    @playground = Playground.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @playground.name_translations.build(field_name: 'name', language: locution.property)
      @playground.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /playgrounds/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@playground)
  end

  # POST /playgrounds
  # POST /playgrounds.json
  def create
    @playground = Playground.new(playground_params)
    @playground.logo.attach(params[:logo])
    metadata_setup(@playground)

    respond_to do |format|
      if @playground.save
        format.html { redirect_to @playground, notice: t('PgCreated') } #'Playground was successfully created.'
        format.json { render json: @playground, status: :created, location: @playground }
      else
        format.html { render action: "new" }
        format.json { render json: @playground.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /playgrounds/1
  # PUT /playgrounds/1.json
  def update
    ### Retrieved by Callback function
    @playground.updated_by = current_login
    if params.has_key?(:logo)
      @playground.logo.purge
      @playground.logo.attach(params[:logo])
    end

    respond_to do |format|
      if @playground.update_attributes(playground_params)
        format.html { redirect_to @playground, notice: t('PgUpdated') } #'Playground was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @playground.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /business_playgrounds/1
  # POST /business_playgrounds/1.json
  def activate
    ### Retrieved by Callback function
    @playground.set_as_active(current_login)

    respond_to do |format|
      if @playground.save
          format.html { redirect_to @playground, notice: t('PgRecalled') } #'Business playground was successfully recalled.'
          format.json { render json: @playground, status: :created, location: @playground }
        else
          format.html { redirect_to @playground, notice: t('PgRecalledKO') } #'Business playground  cannot be recalled.'
          format.json { render json: @playground.errors, status: :unprocessable_entity }
      end
    end
  end

def destroy
  @playground.set_as_inactive(current_login)
  respond_to do |format|
    format.html { redirect_to playgrounds_url, notice: t('PgDeleted') } #'Playground was successfully deleted.'
    format.json { head :no_content }
  end
end

# This defines user's property, to move to the user's controller
def set_as_current
  current_user.update_attributes(:current_playground_id => @playground.id)
  redirect_to root_path, notice: t('PgSwitched') # 'User switched playground.'
end

# GET children from playground, including translations for child index
def get_children
  @business_areas = @playground.business_areas.visible.includes(:name_translations).order([BusinessArea.arel_table[:hierarchy].asc])

  respond_to do |format|
    format.html { render :index } # index.html.erb
    format.json { render json: @business_areas }
    format.js # uses specific template to handle js
  end
end

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current playground
    def set_playground
      @playground = Playground.includes(:owner, :status).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@playground)
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

    def playgrounds
      Playground.arel_table
    end

    def translated_playgrounds
      playgrounds.
      join(owners).on(playgrounds[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(playgrounds[:id].eq(names[:document_id]).and(names[:document_type].eq("Playground")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(playgrounds[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Playground")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [playgrounds[:id], playgrounds[:code], playgrounds[:hierarchy], playgrounds[:name], playgrounds[:description], playgrounds[:status_id], playgrounds[:updated_by], playgrounds[:updated_at], playgrounds[:is_active], playgrounds[:is_current], playgrounds[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not playgrounds.is_active then '0'
          when playgrounds.is_active and playgrounds.is_finalised then '1'
          else '2'
          end").as("calculated_status")]
    end

    def order_by
      [playgrounds[:hierarchy].asc]
    end

  ### strong parameters
  def playground_params
    params.require(:playground).permit(:code, :name, :status_id, :description, :logo,
      :organisation_id, :responsible_id, :deputy_id,
    name_translations_attributes:[:id, :field_name, :language, :translation],
    description_translations_attributes:[:id, :field_name, :language, :translation])
  end


end
