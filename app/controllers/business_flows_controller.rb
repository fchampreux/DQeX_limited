class BusinessFlowsController < ApplicationController
# Check for active session
  before_action :authenticate_user! ## unless ->{:action == 'set_external_reference'}
  load_and_authorize_resource ## except: :set_external_reference

# Retrieve current business flow
  before_action :set_business_flow, only: [:show, :edit, :update, :destroy, :activate, :business_processes]

# Create the list of statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /business_flows
  # GET /business_flows.json
  def index
    @business_flows = BusinessFlow.joins(translated_flows).
                                   pgnd(current_playground).
                                   where("business_flows.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                   visible.
                                   where("code in(?)", current_user.preferred_activities).
                                   select(index_fields).order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @business_flows }
      format.csv { send_data @business_flows.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /business_flows/1
  # GET /business_flows/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /business_flows/new
  # GET /business_flows/new.json
  def new
    @business_area = BusinessArea.find(params[:business_area_id])
    @business_flow = BusinessFlow.new(responsible_id: @business_area.responsible_id,
                                      deputy_id: @business_area.deputy_id,
                                      organisation_id: @business_area.organisation_id)
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @business_flow.name_translations.build(field_name: 'name', language: locution.property)
      @business_flow.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /business_flows/1/edit
  def edit
    ### Retrieved by Callback function
      check_translations(@business_flow)
  end

  # POST /business_flows
  # POST /business_flows.json
  def create
    @business_area = BusinessArea.find(params[:business_area_id])
    @business_flow = @business_area.business_flows.build(business_flow_params)
    metadata_setup(@business_flow)

    respond_to do |format|
      if @business_flow.save
        format.html { redirect_to @business_flow, notice: t('BFCreated') } #'Business flow was successfully created.'
        format.json { render json: @business_flow, status: :created, location: @business_flow }
      else
        format.html { render action: "new" }
        format.json { render json: @business_flow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /business_flows/1
  # PUT /business_flows/1.json
  def update
    ### Retrieved by Callback function
    @business_flow.updated_by = current_login

    respond_to do |format|
      if @business_flow.update_attributes(business_flow_params)
        format.html { redirect_to @business_flow, notice: t('BFUpdated') } #'Business flow was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_flow.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /business_flows/1
  # POST /business_flows/1.json
  def activate
    ### Retrieved by Callback function
    @business_flow.set_as_active(current_login)

    respond_to do |format|
      if @business_flow.save
          format.html { redirect_to @business_flow, notice: t('BFRecalled') } #'Business flow was successfully recalled.'
          format.json { render json: @business_flow, status: :created, location: @business_flow }
        else
          format.html { redirect_to @business_flow, notice: t('BFRecalledKO') } #'Business flow  cannot be recalled.'
          format.json { render json: @business_flow.errors, status: :unprocessable_entity }
      end
    end
  end

def destroy
  @business_flow.set_as_inactive(current_login)
  respond_to do |format|
    format.html { redirect_to business_flows_url, notice: t('BFDeleted') } #'Business flow was successfully deleted.'
    format.json { head :no_content }
  end
end

# GET children from business flow, including translations for child index
def get_children
  @business_processes = @business_flow.business_processes.visible.includes(:name_translations).order([BusinessProcess.arel_table[:hierarchy].asc])

  respond_to do |format|
    format.html { render :index } # index.html.erb
    format.json { render json: @business_processes }
    format.js # uses specific template to handle js
  end
end

  # Business Flow update API to invoke with cURL:
  # curl --noproxy localhost -d @external_activities.json -H "Content-type: application/json" http://localhost/API/external_activities
  def set_external_reference
    puts "Loaded parameters:"
    puts params
    counter = 0
    external_business_flows = params[:activity_entries]
    external_business_flows.each do |business_flow|
      if target_business_flow = BusinessFlow.find_by_name(business_flow[:name][:fr])
        target_business_flow.update_attributes(code: business_flow[:identifier])
        counter += 1
      end
    end
    render json: {"Response": "OK", "Message": "Updated #{counter} business flows"}, status: 200
  end

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business flow
    def set_business_flow
      @business_flow = BusinessFlow.pgnd(current_playground).includes(:owner, :status).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@business_flow)
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

    def flows
      BusinessFlow.arel_table
    end

    def translated_flows
      flows.
      join(owners).on(flows[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(flows[:id].eq(names[:document_id]).and(names[:document_type].eq("BusinessFlow")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(flows[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("BusinessFlow")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [flows[:id], flows[:code], flows[:hierarchy], flows[:name], flows[:description], flows[:status_id], flows[:updated_by], flows[:updated_at], flows[:is_active], flows[:is_current], flows[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not business_flows.is_active then '0'
          when business_flows.is_active and business_flows.is_finalised then '1'
          else '2'
          end").as("calculated_status")]
    end

    def order_by
      [flows[:hierarchy].asc]
    end

  ### strong parameters
  def business_flow_params
    params.require(:business_flow).permit(:code, :name, :status_id, :pcf_index, :pcf_reference, :description, :tr_name, :tr_description,
       :organisation_id, :responsible_id, :deputy_id, :participants, :funding, :active_from, :active_to, :legal_basis, :collect_type_id,
       :uuid,
    name_translations_attributes:[:id, :field_name, :language, :translation],
    description_translations_attributes:[:id, :field_name, :language, :translation],
    :participant_ids => [])
  end

end
