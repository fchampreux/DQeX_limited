class DataPoliciesController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_data_policy, only: [:show, :edit, :update, :destroy]

  # Create the list of roles to be used in the form

    before_action :set_statuses_list, only: [:new, :edit, :update, :create]

    # Initialise breadcrumbs for the resulting view
    before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /policies
  # GET /policies.json
  def index
    @data_policies = DataPolicy.joins(translated_policies).
                                pgnd(current_playground).
                                visible.
                                where("data_policies.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                select(index_fields).
                                order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data_policies }
      format.csv { send_data @data_policies.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /policies/1
  # GET /policies/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /policies/new
  def new
    @data_policy = DataPolicy.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @data_policy.name_translations.build(field_name: 'name', language: locution.property)
      @data_policy.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /policies/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@data_policy)
  end

  # POST /policies
  # POST /policies.json
  def create
    @data_policy = DataPolicy.new(data_policy_params)

    respond_to do |format|
      if @data_policy.save
        format.html { redirect_to @data_policy, notice: t('DPCreated') } #'DataPolicy was successfully created.'
        format.json { render :show, status: :created, location: @data_policy }
      else
        format.html { render :new }
        format.json { render json: @data_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /policies/1
  # PATCH/PUT /policies/1.json
  def update
    @data_policy.updated_by = current_login

    respond_to do |format|
      if @data_policy.update(data_policy_params)
        format.html { redirect_to @data_policy, notice: t('DPUpdated') } #'DataPolicy was successfully updated.'
        format.json { render :show, status: :ok, location: @data_policy }
      else
        format.html { render :edit }
        format.json { render json: @data_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /policies/1
  # POST /policies/1.json
  def activate
    ### Retrieved by Callback function
    @data_policy.set_as_active(current_login)

    respond_to do |format|
      if @data_policy.save
          format.html { redirect_to @data_policy, notice: t('DPRecalled') } #'Business landsacpe was successfully recalled.'
          format.json { render json: @data_policy, status: :created, location: @data_policy }
        else
          format.html { redirect_to @data_policy, notice: t('DPRecalledKO') } # 'Business landsacpe  cannot be recalled.'
          format.json { render json: @data_policy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /policies/1
  # DELETE /policies/1.json
  def destroy
    @data_policy.set_as_inactive(current_login)

    respond_to do |format|
      format.html { redirect_to policies_url, notice: t('DPDeleted') } #'DataPolicy was successfully destroyed.'
      format.json { head :no_content }
    end
  end

  ### private functions
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_data_policy
      @data_policy = DataPolicy.joins(translated_policies).select(index_fields).find(params[:id])
      @cloned_data_policies = DataPolicy.where("hierarchy = ?", @data_policy.hierarchy )
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@data_policy)
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
      Translation.arel_table.alias('tr_territories')
    end

    def organisations
      Translation.arel_table.alias('tr_organisations')
    end

    def business_areas
      Translation.arel_table.alias('tr_business_areas')
    end

    def policies
      DataPolicy.arel_table
    end

    def translated_policies
      policies.
      join(owners).on(policies[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(policies[:id].eq(names[:document_id]).and(names[:document_type].eq("DataPolicy")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(policies[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("DataPolicy")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(territories, Arel::Nodes::OuterJoin).on(policies[:territory_id].eq(territories[:document_id]).and(territories[:document_type].eq("Territory")).and(territories[:language].eq(current_language).and(territories[:field_name].eq('name')))).
      join(organisations, Arel::Nodes::OuterJoin).on(policies[:organisation_id].eq(organisations[:document_id]).and(organisations[:document_type].eq("Organisation")).and(organisations[:language].eq(current_language).and(organisations[:field_name].eq('name')))).
      join(business_areas, Arel::Nodes::OuterJoin).on(policies[:business_area_id].eq(business_areas[:document_id]).and(business_areas[:document_type].eq("BusinessArea")).and(business_areas[:language].eq(current_language).and(business_areas[:field_name].eq('name')))).
      join_sources
    end

    def index_fields
      [policies[:id], policies[:code], policies[:name], policies[:description], policies[:territory_id], policies[:organisation_id], policies[:status_id], policies[:updated_by], policies[:updated_at], policies[:is_active],
        policies[:active_from], policies[:active_to], policies[:created_by], policies[:created_at], policies[:owner_id], policies[:playground_id], policies[:is_finalised], policies[:is_current], policies[:business_area_id],
        policies[:hierarchy],
        policies[:responsible_id],
        policies[:deputy_id],        
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        territories[:translation].as("translated_territory"),
        organisations[:translation].as("translated_organisation"),
        business_areas[:translation].as("translated_business_area"),
        Arel::Nodes::SqlLiteral.new("case
          when not data_policies.is_active then '0'
          when data_policies.is_active and data_policies.is_finalised then '1'
          else '2'
          end").as("calculated_status")]
    end

    def order_by
      [policies[:code].asc]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def data_policy_params
      params.require(:data_policy).permit(:name, :description, :role, :territory_id, :organisation_id, :business_area_id, :created_by, :updated_by, :code, :role_id, :tr_name, :tr_description,
        :active_from, :active_to,
      name_translations_attributes:[:id, :field_name, :language, :translation],
      description_translations_attributes:[:id, :field_name, :language, :translation])
    end
end
