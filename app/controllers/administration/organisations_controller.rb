class Administration::OrganisationsController < AdministrationController
# Check for active session
  before_action :authenticate_user! # unless ->{:action == 'set_external_reference'}
  load_and_authorize_resource # except: :set_external_reference

# Retrieve current business flow
  before_action :set_organisation, only: [:show, :edit, :update, :destroy]

# Create the list of statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /organisations
  # GET /organisations.json
  def index
    @organisations = Organisation.joins(translated_organisations).
                                  where("organisations.owner_id = ? or ? is null", params[:owner], params[:owner]).
                                  visible.
                                  select(index_fields).
                                  order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisations }
      format.csv { send_data @organisations.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /organisations/1
  # GET /organisations/1.json
  def show
    ### Retrieved by Callback function
  end

  # GET /organisations/new
  # GET /organisations/new.json
  def new
    @parent = Organisation.find(params[:organisation_id])
    @organisation = Organisation.new
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @organisation.name_translations.build(field_name: 'name', language: locution.property)
      @organisation.description_translations.build(field_name: 'description', language: locution.property)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organisation }
    end
  end

  # GET /organisations/1/edit
  def edit
    ### Retrieved by Callback function
      check_translations(@organisation)
  end

  # POST /organisations
  # POST /organisations.json
  def create
    @parent = Organisation.find(params[:organisation_id])
    @organisation = @parent.child_organisations.build(organisation_params)
    metadata_setup(@organisation)

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to [:administration, @organisation], notice: t('OrgCreated') } #'Organisation was successfully created.'
        format.json { render json: @organisation, status: :created, location: @organisation }
      else
        format.html { render action: "new" }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organisations/1
  # PUT /organisations/1.json
  def update
    ### Retrieved by Callback function
    @organisation.updated_by = current_login

    respond_to do |format|
      if @organisation.update_attributes(organisation_params)
        format.html { redirect_to [:administration, @organisation], notice: t('OrgUpdated') } #'Organisation was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.json
  def destroy
    ### Retrieved by Callback function
    @organisation.destroy

    respond_to do |format|
      format.html { redirect_to administration_organisations_url }
      format.json { head :no_content }
    end
  end

  # Organisation update API to invoke with cURL:
  # curl --noproxy localhost -d @external_organisations.json -H "Content-type: application/json" http://localhost/API/external_organisations
  def set_external_reference
    puts "Loaded parameters:"
    puts params
    counter = 0
    external_organisations = params[:organisation_entries]
    external_organisations.each do |organisation|
      if target_organisation = Organisation.find_by_name(organisation[:name].downcase)
        target_organisation.update_attributes(external_reference: organisation[:identifier])
        counter += 1
      end
    end
    render json: {"Response": "OK", "Message": "Updated #{counter} organisations"}, status: 200
  end


### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current organisation
    def set_organisation
      @organisation = Organisation.pgnd(current_playground).includes(:owner, :status, :parent).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@organisation)
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

    def organisations
      Organisation.arel_table
    end

    def translated_organisations
      organisations.
      join(owners).on(organisations[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(organisations[:id].eq(names[:document_id]).and(names[:document_type].eq("Organisation")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(organisations[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Organisation")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [organisations[:id], organisations[:code], organisations[:hierarchy], organisations[:name], organisations[:description], organisations[:status_id], organisations[:updated_by], organisations[:updated_at], organisations[:is_active], organisations[:is_current], organisations[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not organisations.is_active then '0'
          else '1'
          end").as("calculated_status")]
    end

    def order_by
      [organisations[:hierarchy].asc]
    end

    def set_breadcrumbs
      object = @organisation
      way_back = [object]
      while object.organisation_level > 1 # stop when reaches highest level
        path = object.ancestor
        way_back << path
        object = path
      end
      puts way_back.reverse
      @breadcrumbs = way_back.reverse
    end

  ### strong parameters
  def organisation_params
    params.require(:organisation).permit(:code, :name, :description, :parent_id, :status_id, :tr_name, :tr_description,
    name_translations_attributes:[:id, :field_name, :language, :translation],
    description_translations_attributes:[:id, :field_name, :language, :translation])
  end

end
