class ActivitiesController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current business rule
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :get_children]

# Create the selection lists be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]

  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /activities
  # GET /activities.json
  def index
    # Filtering by parent_id allows to use the same index in parent/child show view
    if params[:my_parent].blank?
      @activities = Activity.joins(translated_activities).pgnd(current_playground).visible.
        select(index_fields).order(order_by)
    else
      @activities = Activity.joins(translated_activities).
                              pgnd(current_playground).
                              visible.
                              where("activities.owner_id = ? or ? is null", params[:owner], params[:owner]).
                              where("business_process_id = ? ", params[:my_parent]).
                              select(index_fields).
                              order(order_by)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @activities }
      format.csv { send_data @activities.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
    ### Retrieved by Callback function
    if @activity.source_object and @activity.target_object
      # Generate graphviz title
      title = GraphViz.new( :G, :type => :digraph, rankdir: 'LR' )
      from = title.add_node(@activity.source_object.code, shape: 'record')
      to = title.add_node(@activity.target_object.code, shape: 'record')
      title.add_edges(from, to)
      title.output(svg: "app/assets/images/temporary_images/Activity_title#{@activity.id}.svg")
    end
    # Generate graphviz
    graph = GraphViz.new( :G, type: :digraph, rankdir: 'LR' )
    @activity.tasks.order(:sort_code).each do |node|
    case node.node_type.code
    when 'START'
      node_color = 'blue'
    when 'END'
      node_color = 'green'
    when 'RESCUE'
      node_color = 'red'
    else
      node_color = 'black'
    end
    #graph.add_node(name: node.code, tooltip: translation_for(node.name_translations)).color = node_color
    graph.add_node(node.code,
                  color: node_color,
                  tooltip: translation_for(node.name_translations))
    end
    @activity.tasks.order(:sort_code).each do |node|
      if node.success_next
        graph.add_edge(node.code, node.success_next.code)
      end
      if node.failure_next
        graph.add_edge(node.code, node.failure_next.code).color = 'red'
      end
    end
    graph.output(svg: "app/assets/images/temporary_images/Activity_flow#{@activity.id}.svg")
  end

  # GET /activities/new
  # GET /activities/new.json
  def new
    @business_process = BusinessProcess.find(params[:business_process_id])
    @activity = Activity.new(parent: @business_process,
                            parameters: @business_process.parameters,
                            responsible_id: @business_process.responsible_id,
                            deputy_id: @business_process.deputy_id,
                            organisation_id: @business_process.organisation_id,
                            node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "PROCESS" }.id || 0,
                            technology_id:  values_options_for('Technologies', 1).find { |x| x["code"] == "Linux" }.id || 0)
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @activity.name_translations.build(field_name: 'name', language: locution.property)
      @activity.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /activities/1/edit
  def edit
    ### Retrieved by Callback function
      check_translations(@activity)
  end

  # POST /activities
  # POST /activities.json
  def create
    @business_process = BusinessProcess.find(params[:business_process_id])
    @activity = @business_process.activities.build(activity_params)
    metadata_setup(@activity)
    json_parameters_serialization(@activity)
    @activity.sort_code = '30'

    # Create child tasks
    ending = @activity.tasks.build(playground_id: @activity.playground_id,
                                  organisation_id: @activity.organisation_id,
                                  responsible_id: @activity.responsible_id,
                                  deputy_id: @activity.deputy_id,
                                  code: "END",
                                  name: "Ending task",
                                  node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "END" }.id || 0,
                                  status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                                  technology_id: @activity.technology_id,
                                  owner_id: @activity.owner_id,
                                  created_by: current_login,
                                  updated_by: current_login,
                                  sort_code: "90",
                                  parameters: @activity.parameters)
    ending.name_translations.build(field_name: "name",
                                  language: current_language,
                                  translation: ending.name)
    starting = @activity.tasks.build(playground_id: @activity.playground_id,
                                    organisation_id: @activity.organisation_id,
                                    responsible_id: @activity.responsible_id,
                                    deputy_id: @activity.deputy_id,
                                    code: "START",
                                    name: "Starting task",
                                    node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "START" }.id || 0,
                                    status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                                    technology_id: @activity.technology_id,
                                    owner_id: @activity.owner_id,
                                    created_by: current_login,
                                    updated_by: current_login,
                                    sort_code: "00",
                                    success_next_id: ending.id,
                                    failure_next_id: ending.id,
                                    parameters: @activity.parameters)
    starting.name_translations.build(field_name: "name",
                                    language: current_language,
                                    translation: starting.name)
    rescuing = @activity.tasks.build(playground_id: @activity.playground_id,
                                    organisation_id: @activity.organisation_id,
                                    responsible_id: @activity.responsible_id,
                                    deputy_id: @activity.deputy_id,
                                    code: "RESCUE",
                                    name: "Rescuing task",
                                    node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "RESCUE" }.id || 0,
                                    status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                                    technology_id: @activity.technology_id,
                                    owner_id: @activity.owner_id,
                                    created_by: current_login,
                                    updated_by: current_login,
                                    sort_code: "99",
                                    #success_next_id: ending.id,
                                    #failure_next_id: ending.id,
                                    parameters: @activity.parameters)
    rescuing.name_translations.build(field_name: "name",
                                    language: current_language,
                                    translation: rescuing.name)

    respond_to do |format|
      if @activity.save
        # Link Start to End
        starting.update_attributes(success_next_id: ending.id, failure_next_id: rescuing.id)
        format.html { redirect_to @activity, notice: t('.Success') } #'Activity was successfully created.'
        format.json { render json: @activity, status: :created, location: @activity }
      else
        format.html { render action: "new", notice: t('.Failure') }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.json
  def update
    ### Retrieved by Callback function
    @activity.updated_by = current_login
    @activity.sort_code = Parameter.find(activity_params[:node_type_id]).property
    json_parameters_serialization(@activity)

    respond_to do |format|
      if @activity.update_attributes(activity_params)
        format.html { redirect_to @activity, notice: t('.Success') } #'Activity was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit", notice: t('.Failure') }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /activitys/1
  # POST /activitys/1.json
  def activate
    ### Retrieved by Callback function
    @activity.set_as_active(current_login)

    respond_to do |format|
      if @activity.save
          format.html { redirect_to @activity, notice: t('.Success') } #'Activity was successfully recalled.'
          format.json { render json: @activity, status: :created, location: @activity }
        else
          format.html { redirect_to @activity, notice: t('.Failure') } #'Activity  cannot be recalled.'
          format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

def destroy
  @activity.destroy
  respond_to do |format|
    format.html { redirect_to @activity.parent, notice: t('.Success') } # 'Activity was successfully deleted.'
    format.json { head :no_content }
  end
end

def get_children
  @child_tasks = @activity.tasks.includes(:name_translations).order(:sort_code)

  respond_to do |format|
    format.html { render :index } # index.html.erb
    format.json { render json: @child_tasks }
    format.js # uses specific template to handle js
  end
end

  ### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current activity
    def set_activity
      @activity = Activity.pgnd(current_playground).includes(:owner, :status).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@activity)
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

    def business_objects
      BusinessObject.arel_table
    end

    def activities
      Activity.arel_table
    end

    def translated_activities
      activities.
      join(owners).on(activities[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(activities[:id].eq(names[:document_id]).and(names[:document_type].eq("Activity")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(activities[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Activity")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(business_objects, Arel::Nodes::OuterJoin).on(business_objects[:id].eq(activities[:target_object_id])).
      join_sources
    end

    def index_fields
      [activities[:id], activities[:code], activities[:hierarchy], activities[:sort_code], activities[:status_id], activities[:updated_by], activities[:updated_at],
        business_objects[:code].as("object_type"),
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not activities.is_active then '0'
          when activities.is_active and activities.is_finalised then '1'
          else '2'
        end").as("calculated_status")]
    end

    def order_by
      [activities[:sort_code].desc]
    end

    ### strong parameters
    def activity_params
      params.require(:activity).permit(:id,
                                      :code,
                                      :name,
                                      :status_id,
                                      :description,
                                      :source_object_id,
                                      :target_object_id,
                                      :gsbpm_id,
                                      :node_type_id,
                                      :parameters,
                                      :template_id,
                                      :is_template,
                                      :is_synchro,
                                      :failure_next_id,
                                      :success_next_id,
                                      :technology_id,
                                      :params_file_path,
                                      :params_file_name,
                                      # :log_file_path,
                                      # :log_file_name,
      name_translations_attributes:[:id, :field_name, :language, :translation],
      description_translations_attributes:[:id, :field_name, :language, :translation])
    end

end
