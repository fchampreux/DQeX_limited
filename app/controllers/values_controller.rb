class ValuesController < ApplicationController
    # Check for active session
      before_action :authenticate_user!
      load_and_authorize_resource

    # Retrieve current value
      before_action :set_value, only: [:show, :edit, :update, :destroy, :child_values, :child_values_count]


  def new
    # If the value is created as the child of another value, then the parent value is assigned as superior
    @values_list = ValuesList.find(params[:values_list_id])
    if params.has_key?(:parent_id)
      @superior = Value.find(params[:parent_id])
      @value = @values_list.values.build(playground_id: @values_list.playground_id, parent_id: @superior.id, level: @superior.level.next)
    else
      @value = @values_list.values.build(playground_id: @values_list.playground_id)
    end
    list_of_languages.each do |locution|
      @value.name_translations.build(field_name: 'name', language: locution.property)
      @value.alias_translations.build(field_name: 'alias', language: locution.property)
      @value.abbreviation_translations.build(field_name: 'abbreviation', language: locution.property)
      @value.description_translations.build(field_name: 'description', language: locution.property)
    end
    render layout: false
  end

  def edit
    # value retrieved by callback
    check_translations(@value)
    render layout: false
  end

  def create
    @values_list = ValuesList.find(params[:values_list_id])
    @value = @values_list.values.build(value_params)
    if params[:anything]
      @value.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @value.anything = nil
    end

    respond_to do |format|
      if @value.save
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Skill was successfully updated.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@value.errors.full_messages.join(',')}" }
        format.json { render json: @value.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # value retrieved by callback
    @values_list = ValuesList.find(@value.values_list_id)
    if params[:anything]
      @value.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]}
    else
      @value.anything = nil
    end

    respond_to do |format|
      if @value.update_attributes(value_params)
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Skill was successfully updated.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@value.errors.full_messages.join(',')}" }
        format.json { render json: @value.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    # value retrieved by callback
    render layout: false

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @value }
      format.csv { send_data @value.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def destroy
    # value retrieved by callback
    @value.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: t('.Success') } # 'Business object was successfully deleted.'
      format.json { head :no_content }
    end
  end

  def child_values
    @child_values = @value.subs.includes(:name_translations).order(:code)

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @child_values }
      format.js # uses specific template to handle js
    end
  end

  def child_values_count
    @child_values_count = @value.subs.count

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @child_values_count }
      format.js # uses specific template to handle js
    end
  end

  # GET children from @classification values, including translations for child index
  def get_children
    #@values = @value.child_values.where("values_to_values.classification_id = ?", @classification.id).includes(:name_translations).order(:code)
    @values = @value.child_values.where("values_to_values.classification_id = ?", params[:classification_id]).includes(:name_translations).order(:code)
    @values.each do |child|
      child.classification_id = params[:classification_id]
    end

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @values }
      format.js # uses specific template to handle js
    end
  end

  ### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current value
    def set_value
      @value = Value.find(params[:id])
      @values_list = ValuesList.find(@value.values_list_id)
      #@annotations = @value.annotations
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@value)
    end

    ### queries tayloring

    def names
      Translation.arel_table.alias('tr_names')
    end

    def aliases
      Translation.arel_table.alias('tr_alias')
    end

    def abbreviations
      Translation.arel_table.alias('tr_abbs')
    end

    def descriptions
      Translation.arel_table.alias('tr_descriptions')
    end

    def external_descriptions
      Translation.arel_table.alias('tr_external_descriptions')
    end

    def values
      value.arel_table
    end

    def translated_values
      values.
      join(names, Arel::Nodes::OuterJoin).on(values[:id].eq(names[:document_id]).and(names[:document_type].eq("value")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(aliases, Arel::Nodes::OuterJoin).on(values[:id].eq(aliases[:document_id]).and(aliases[:document_type].eq("value")).and(aliases[:language].eq(current_language).and(aliases[:field_name].eq('aliase')))).
      join(abbreviations, Arel::Nodes::OuterJoin).on(values[:id].eq(abbreviations[:document_id]).and(abbreviations[:document_type].eq("value")).and(abbreviations[:language].eq(current_language).and(abbreviations[:field_name].eq('abbreviation')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(values[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("value")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(external_descriptions, Arel::Nodes::OuterJoin).on(values[:id].eq(external_descriptions[:document_id]).and(external_descriptions[:document_type].eq("value")).and(external_descriptions[:language].eq(current_language).and(external_descriptions[:field_name].eq('external_description')))).
      join_sources
    end

    def index_fields
      [values[:id], values[:code], values[:name], values[:description], values[:updated_at], values[:values_list_id], values[:parent_id], values[:level],
       names[:translation].as("translated_name"),
       aliases[:translation].as("translated_alias"),
       abbreviations[:translation].as("translated_abbreviation"),
       descriptions[:translation].as("translated_description")]
    end

    def order_by
      [values[:created_at].asc]
    end

  ### strong parameters
  def value_params
    params.require(:value).permit(:playground_id, :values_list_id, :code, :name, :description, :parent_id, :level_id, :parent_code,
      :alternate_code, :alias, :anything, :alias, :abbreviation, :uri, :sort_code,
        annotations_attributes: [:playground_id, :value_id, :annotation_type_id,  :uri, :code, :name, :id, :_destroy,
          description_translations_attributes: [:id, :field_name, :language, :translation, :_destroy]],
        name_translations_attributes: [:id, :field_name, :language, :translation, :_destroy],
        #alias_translations_attributes: [:id, :field_name, :language, :translation, :_destroy],
        #abbreviation_translations_attributes: [:id, :field_name, :language, :translation, :_destroy],
        description_translations_attributes: [:id, :field_name, :language, :translation, :_destroy])
  end

end
