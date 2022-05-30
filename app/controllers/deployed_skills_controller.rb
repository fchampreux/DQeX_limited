class DeployedSkillsController < ApplicationController
  # Check for active session
    before_action :authenticate_user!
    load_and_authorize_resource

  # Retrieve current skill
    before_action :set_skill, only: [:show, :edit, :update, :destroy]

    before_action :evaluate_completion, only: [:show, :propose, :accept, :reject, :reopen]

    # Initialise breadcrumbs for the resulting view
    before_action :set_breadcrumbs, only: [:show, :edit, :update]

  def index
    @skills = DeployedSkill.joins(translated_skills).
                            pgnd(current_playground).
                            visible.
                            search(params[:criteria]).
                            where("skills.owner_id = ? or ? is null", params[:owner], params[:owner]).
                            select(index_fields).
                            order(order_by).
                            paginate(page: params[:page], :per_page => params[:per_page])

      respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @skills }
      format.csv { send_data @skills.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def index_short
    @skills = DeployedSkill.joins(translated_skills).pgnd(current_playground).owned_by(current_user).search(params[:criteria]).
      select(index_fields).order(order_by).paginate(page: params[:page], :per_page=> params[:per_page])

      respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @skills }
      format.csv { send_data @skills.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def show
    # skill retrieved by callback

    # Retrieve filtered value domain for the deployed skill
    if ValuesList.exists?(id: @skill.values_list_id)
      @filtered_values = @skill.values_list.values.where("#{@skill.filter}").order(:sort_code).paginate(page: params[:page], :per_page => paginate_lines)
      @child_values += @filtered_values
    end

    # Retrieve filtered extra values for the deployed skill
    @values_lists_links = @skill.skills_values_lists
    @skill.skills_values_lists.each do |list|
      @additional_values = list.reference.values.where("#{list.filter}")
      @child_values += @additional_values
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @skill }
      format.csv { send_data @skill.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  def edit
    # skill retrieved by callback
    check_translations(@skill)
  end

  def update
    # skill retrieved by callback
    if params[:anything]
      @skill.anything = params[:anything].to_enum.to_h.to_a.map {|row| row[1]} if params[:anything]
    else
      @skill.anything = nil
    end
    @skill.updated_by = current_login

    respond_to do |format|
      if @skill.update_attributes(deployed_skill_params)
        format.html { redirect_to @skill, notice: t('.Success') } #'Skill was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit", notice: t('.Failure') }
        format.json { render json: @skill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /skills/1
  # DELETE /skills/1.json
  def destroy
    # skill retrieved by callback
    @skill.destroy

    respond_to do |format|
      format.html { redirect_to @skill.parent, notice: t('.Success') } #'Skill was successfully removed.'
      format.json { head :no_content }
    end

  end

  ### private functions
    private

    ### Use callbacks to share common setup or constraints between actions.
      # Retrieve current skill
    def set_skill
      @skill = DeployedSkill.find(params[:id])
      @child_values = Value.where(id: -1) # Initialise empty set
      #@annotations = @skill.annotations
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@skill)
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

    def external_descriptions
      Translation.arel_table.alias('tr_external_descriptions')
    end

    def skills
      DefinedSkill.arel_table
    end

    # Queries tayloring
    def translated_skills
      skills.
      join(owners).on(skills[:responsible_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(skills[:id].eq(names[:document_id]).and(names[:document_type].eq("Skill")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(skills[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Skill")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(external_descriptions, Arel::Nodes::OuterJoin).on(skills[:id].eq(external_descriptions[:document_id]).and(external_descriptions[:document_type].eq("Skill")).and(external_descriptions[:language].eq(current_language).and(external_descriptions[:field_name].eq('external_description')))).
      join_sources
    end

    def index_fields
      [skills[:id], skills[:code], skills[:name], skills[:description], skills[:status_id], skills[:is_template], skills[:updated_by], skills[:updated_at], skills[:responsible_id], skills[:workflow_state], skills[:business_object_id], skills[:values_list_id], skills[:classification_id],
        owners[:name].as("responsible_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
        when not skills.is_active then '0'
        when skills.is_active and skills.is_finalised then '1'
        else '2'
          end").as("calculated_status")]
    end

    def order_by
      [skills[:created_at].asc]
    end

  ### strong parameters
  def deployed_skill_params
    params.require(:deployed_skill).permit(:playground_id, :business_object_id, :template_skill_id, :code, :name, :status_id, :description, :tr_name, :tr_description,
      :skill_type_id, :skill_size, :skill_min_size, :skill_precision, :skill_unit_id, :skill_role_id, :skill_aggregation_id, :values_list_id, :values_list_scope,
      :is_mandatory, :is_array, :is_pk, :is_ak, :is_published, :sensitivity_id, :regex_pattern, :source_type_id, :anything,
      :external_description, :is_pairing_key, :min_value, :max_value, :has_hierarchical_values, :_destroy, :id, :classification_id, :filter,
      :valid_from, :valid_to, :organisation_id, :responsible_id, :deputy_id,
        skills_values_lists_attributes: [:id, :playground_id, :type_id,  :values_list_id, :filter, :description, :_destroy ],
        name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        external_description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
        annotations_attributes: [:playground_id, :value_id, :annotation_type_id,  :uri, :code, :name, :id, :_destroy,
          description_translations_attributes: [:id, :field_name, :language, :translation, :_destroy]])
  end

  def evaluate_completion
    @completion_status = Array.new
    # translations
    @completion_status[0] = (1 - Translation.where("document_type = 'Skill' and document_id = ? and field_name = 'name' and translation = '' ", @skill.id).count.to_f / list_of_languages.length) * 100.00
    # values_list reference
    if ValuesList.exists?(id: @skill.values_list_id)
      if @skill.references.any?
        @completion_status[1] = ((ValuesList.find(@skill.values_list_id).is_finalised ? 1 : 0) + (@skill.references.map { |r| r.is_finalised ? 1.0 : 0.0 }.reduce(:+))) / (@skill.references.count + 1) * 100
      else
        @completion_status[1] = (ValuesList.find(@skill.values_list_id).is_finalised ? 1 : 0) * 100
      end
    else
      if @skill.references.any?
        @completion_status[1] = (@skill.references.map { |r| r.is_finalised ? 1.0 : 0.0 }.reduce(:+)) / @skill.references.count * 100
      else
        @completion_status[1] = nil
      end
    end
    # linked variables
    @completion_status[2] = @skill.template_skill.is_finalised ? 100 : 0
    # responsibilities
    @completion_status[3] = ((@skill.organisation_id != 0 ? 1 : 0) + (@skill.responsible_id != 0 ? 1 : 0) + (@skill.deputy_id != 0 ? 1 : 0)).to_f / 3 * 100.00
    # data types completion / consitency
    @completion_status[4] = ((@skill.skill_type_id == options_for('data_types').find { |x| x["code"] == "CODE-LIST" }.id) ^ !(@skill.skill_size == 0 or @skill.skill_size.blank? )) ? 100 : 0
    # existence of Primary Key
    @completion_status[5] = nil
  end

end
