class Administration::ParametersController < AdministrationController
  # Check for active session
    before_action :authenticate_user!
    load_and_authorize_resource

  # Retrieve current parameter
    before_action :set_parameter, only: [:show, :edit, :update, :destroy]

  def new
    # If the parameteris created as the child of another parameter, then the parent parameteris assigned as superior
    @parameters_list = ParametersList.find(params[:parameters_list_id])
    @parameter= @parameters_list.parameters.build(playground_id: @parameters_list.playground_id)
    list_of_languages.each do |locution|
      @parameter.name_translations.build(field_name: 'name', language: locution.property)
      @parameter.description_translations.build(field_name: 'description', language: locution.property)
    end
    render layout: false
  end

  def edit
    # parameterretrieved by callback
    check_translations(@parameter)
    render layout: false
  end

  def create
    @parameters_list = ParametersList.find(params[:parameters_list_id])
    @parameter= @parameters_list.parameters.build(parameter_params)

    respond_to do |format|
      if @parameter.save
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Skill was successfully updated.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@parameter.errors.full_messages.join(',')}" }
        format.json { render json: @parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # parameterretrieved by callback
    @parameters_list = ParametersList.find(@parameter.parameters_list_id)

    respond_to do |format|
      if @parameter.update_attributes(parameter_params)
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Skill was successfully updated.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@parameter.errors.full_messages.join(',')}" }
        format.json { render json: @parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    # parameterretrieved by callback
    render layout: false

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @parameter}
      format.csv { send_data @parameter.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def destroy
    # parameterretrieved by callback
    @parameter.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: t('.Success') } # 'Parameter was successfully deleted.'
      format.json { head :no_content }
    end
  end

  ### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current parameter
    def set_parameter
      @parameter= Parameter.find(params[:id])
      @parameters_list = ParametersList.find(@parameter.parameters_list_id)
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@parameter)
    end

    ### queries tayloring

    def names
      Translation.arel_table.alias('tr_names')
    end

    def descriptions
      Translation.arel_table.alias('tr_descriptions')
    end

    def parameters
      parameter.arel_table
    end

    def translated_parameters
      parameters.
      join(names, Arel::Nodes::OuterJoin).on(parameters[:id].eq(names[:document_id]).and(names[:document_type].eq("Parameter")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(parameters[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Parameter")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end


    def index_fields
      [parameters[:id], parameters[:code], parameters[:sort_code], parameters[:name], parameters[:description], parameters[:property], parameters[:scope], parameters[:active_to], parameters[:active_from],
       names[:translation].as("translated_name"),
       descriptions[:translation].as("translated_description")]
    end

    def order_by
      [parameters[:sort_code].asc]
    end

  ### strong parameters
  def parameter_params
    params.require(:parameter).permit(:playground_id, :parameters_list_id, :code, :name, :description, :property, :scope, :active_from, :active_to,
        name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy])
  end

end
