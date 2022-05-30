class BusinessAreasController < ApplicationController
# Check for active session
  before_action :authenticate_user! # unless ->{:action == 'set_external_reference'}
  load_and_authorize_resource # except: :set_external_reference

# Retrieve current business area
  before_action :set_business_area, only: [:show, :edit, :update, :destroy, :activate, :business_flows]

# Create the list of statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /business_areas
  # GET /business_areas.json
  def index
    @business_areas = BusinessArea.joins(translated_areas).
                                    pgnd(current_playground).
                                    where("business_areas.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                    visible.
                                    select(index_fields).
                                    order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @business_areas }
      format.csv { send_data @business_areas.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /business_areas
  # GET /business_areas.json
  def index_short
    @business_areas = BusinessArea.joins(translated_areas).pgnd(current_playground).owned_by(current_user).
      select(index_fields).order(order_by)

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @business_areas }
      format.csv { send_data @business_areas.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /business_areas/1
  # GET /business_areas/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /business_areas/new
  # GET /business_areas/new.json
  def new
    @business_area = BusinessArea.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @business_area.name_translations.build(field_name: 'name', language: locution.property)
      @business_area.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /business_areas/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@business_area)
  end

  # POST /business_areas
  # POST /business_areas.json
  def create
    @business_area = BusinessArea.new(business_area_params)
    metadata_setup(@business_area)

    respond_to do |format|
      if @business_area.save
        format.html { redirect_to @business_area, notice: t('BACreated') }
        format.json { render json: @business_area, status: :created, location: @business_area }
      else
        format.html { render action: "new" }
        format.json { render json: @business_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /business_areas/1
  # PUT /business_areas/1.json
  def update
    ### Retrieved by Callback function
    @business_area.updated_by = current_login

    respond_to do |format|
      if @business_area.update_attributes(business_area_params)
        format.html { redirect_to @business_area, notice: t('BAUpdated') } #'Business area was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /business_areas/1
  # POST /business_areas/1.json
  def activate
    ### Retrieved by Callback function
    @business_area.set_as_active(current_login)

    respond_to do |format|
      if @business_area.save
          format.html { redirect_to @business_area, notice: t('BARecalled') }  # Business area was successfully recalled.
          format.json { render json: @business_area, status: :created, location: @business_area }
        else
          format.html { redirect_to @business_area, notice: t('BARecalledKO') }  # Business area cannot be recalled.
          format.json { render json: @business_area.errors, status: :unprocessable_entity }
      end
    end
  end

    # DELETE /business_areas/1
    # DELETE /business_areas/1.json
  def destroy
    @business_area.set_as_inactive(current_login)

    respond_to do |format|
      format.html { redirect_to business_areas_url, notice: t('BADeleted') } # Business area was successfully deleted.
      format.json { head :no_content }
    end
  end

  # GET children from business area, including translations for child index
  def get_children
    @business_flows = @business_area.business_flows.visible.includes(:name_translations).order([BusinessFlow.arel_table[:hierarchy].asc])

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @business_flows }
      format.js # uses specific template to handle js
    end
  end

  # Business Area update API to invoke with cURL:
  # curl --noproxy localhost -d @external_domains.json -H "Content-type: application/json" http://localhost/API/external_domains
  def set_external_reference
    puts "Loaded parameters:"
    puts params
    counter = 0
    external_business_areas = params[:information_domain_entries]
    external_business_areas.each do |business_area|
      if target_business_area = BusinessArea.find_by_name(business_area[:name][:fr])
        target_business_area.update_attributes(uuid: business_area[:id])
        counter += 1
      end
    end
    render json: {"Response": "OK", "Message": "Updated #{counter} business areas"}, status: 200
  end

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business area
    def set_business_area
      @business_area = BusinessArea.pgnd(current_playground).includes(:owner, :status).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@business_area)
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

    def areas
      BusinessArea.arel_table
    end

    def translated_areas
      areas.
      join(owners).on(areas[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(areas[:id].eq(names[:document_id]).and(names[:document_type].eq("BusinessArea")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(areas[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("BusinessArea")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [areas[:id], areas[:code], areas[:hierarchy], areas[:name], areas[:description], areas[:status_id], areas[:updated_by], areas[:updated_at], areas[:is_active], areas[:is_current], areas[:is_finalised], areas[:playground_id],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not business_areas.is_active then '0'
          when business_areas.is_active and business_areas.is_finalised then '1'
          else '2'
          end").as("calculated_status")]
    end

    def order_by
      [areas[:hierarchy].asc]
    end

  ### strong parameters
  def business_area_params
    params.require(:business_area).permit(:code, :name, :status_id, :pcf_index, :pcf_reference, :description, :id, :tr_name, :tr_description, :responsible_id, :deputy_id,
    name_translations_attributes:[:id, :field_name, :language, :translation],
    description_translations_attributes:[:id, :field_name, :language, :translation])
  end

end
