class BusinessProcessesController < ApplicationController
  include BusinessProcessesHelper
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current business process
  before_action :set_business_process, only: [:show, :edit, :update, :schedule, :destroy]

# Create the list of statuses to be used in the form
  before_action :set_statuses_list, only: [:new, :edit, :update, :create]


  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /business_processes
  # GET /business_processes.json
  def index
    @business_processes = BusinessProcess.joins(translated_processes).pgnd(current_playground).visible.
      select(index_fields).order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @business_processes }
      format.csv { send_data @business_processes.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /business_processes
  # GET /business_processes.json
  def index_short
    @business_processes = BusinessProcess.joins(translated_processes).pgnd(current_playground).owned_by(current_user).
      select(index_fields).order(order_by)

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @business_processes }
      format.csv { send_data @business_processes.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /business_processes/1
  # GET /business_processes/1.json
  def show
    ### Retrieved by Callback function
    if @business_process.zone_from and @business_process.zone_to
      # Generate graphviz title
      title = GraphViz.new( :G, type: :digraph, rankdir: 'LR' )
      from = title.add_node(@business_process.zone_from.property, shape: 'record')
      to = title.add_node(@business_process.zone_to.property, shape: 'record')
      title.add_edges(from, to)
      title.output(svg: "app/assets/images/temporary_images/#{@business_process.class.name}_title#{@business_process.id}.svg")
    end
    # Generate graphviz
    graph = GraphViz.new( :G, type: :digraph, rankdir: 'LR' )
    @business_process.activities.order(:sort_code).each do |node|
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
      graph.add_node(node.code,
                    URL: activity_path(node.id),
                    target: "_blank",
                    color: node_color,
                    tooltip: translation_for(node.name_translations))
    end
    @business_process.activities.order(:sort_code).each do |node|
      if node.success_next
        graph.add_edge(node.code, node.success_next.code)
      end
      if node.failure_next
        graph.add_edge(node.code, node.failure_next.code).color = 'red'
      end
    end
    graph.output(svg: "app/assets/images/temporary_images/#{@business_process.class.name}_flow#{@business_process.id}.svg")
  end

  # GET /business_processes/new
  # GET /business_processes/new.json
  def new
    @business_flow = BusinessFlow.find(params[:business_flow_id])
    @business_process = BusinessProcess.new(responsible_id: @business_flow.responsible_id,
                                            deputy_id: @business_flow.deputy_id,
                                            organisation_id: @business_flow.organisation_id)
    @business_process.parameters = [{"name":"script_path","dataType":"STRING","value":"","isMandatory":"true"},
                                    {"name":"script_name","dataType":"STRING","value":"","isMandatory":"true"},
                                    {"name":"log_file_name","dataType":"STRING","value":"","isMandatory":""},
                                    {"name":"log_file_path","dataType":"STRING","value":"","isMandatory":""},
                                    {"name":"WorkflowObjectId","dataType":"STRING","value":"","isMandatory":""}]
    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @business_process.name_translations.build(field_name: 'name', language: locution.property)
      @business_process.description_translations.build(field_name: 'description', language: locution.property)
    end
  end

  # GET /business_processes/1/edit
  def edit
    ### Retrieved by Callback function
      check_translations(@business_process)
  end

  # POST /business_processes
  # POST /business_processes.json
  def create
    @business_flow = BusinessFlow.find(params[:business_flow_id])
    @business_process = @business_flow.business_processes.build(business_process_params)
    @business_process.sort_code = @business_process.zone_from&.sort_code
    metadata_setup(@business_process)
    json_parameters_serialization(@business_process)

    # Create child activities
    ending = @business_process.activities.build(playground_id: @business_process.playground_id,
                                                organisation_id: @business_process.organisation_id,
                                                responsible_id: @business_process.responsible_id,
                                                deputy_id: @business_process.deputy_id,
                                                code: "END",
                                                name: "Ending activity",
                                                node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "END" }.id || 0,
                                                status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                                                technology_id: values_options_for('Technologies', 1).find { |x| x["code"] == "Linux" }.id || 0,
                                                owner_id: @business_process.owner_id,
                                                created_by: current_login,
                                                updated_by: current_login,
                                                sort_code: "90",
                                                parameters: @business_process.parameters)
    ending.name_translations.build(field_name: "name",
                                  language: current_language,
                                  translation: ending.name)
    starting = @business_process.activities.build(playground_id: @business_process.playground_id,
                                                  organisation_id: @business_process.organisation_id,
                                                  responsible_id: @business_process.responsible_id,
                                                  deputy_id: @business_process.deputy_id,
                                                  code: "START",
                                                  name: "Starting activity",
                                                  node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "START" }.id || 0,
                                                  status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                                                  technology_id: values_options_for('Technologies', 1).find { |x| x["code"] == "Linux" }.id || 0,
                                                  owner_id: @business_process.owner_id,
                                                  created_by: current_login,
                                                  updated_by: current_login,
                                                  sort_code: "00",
                                                  success_next_id: ending.id,
                                                  failure_next_id: ending.id,
                                                  parameters: @business_process.parameters)
    starting.name_translations.build(field_name: "name",
                                    language: current_language,
                                    translation: starting.name)
    rescuing = @business_process.activities.build(playground_id: @business_process.playground_id,
                                                  organisation_id: @business_process.organisation_id,
                                                  responsible_id: @business_process.responsible_id,
                                                  deputy_id: @business_process.deputy_id,
                                                  code: "RESCUE",
                                                  name: "Rescuing activity",
                                                  node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "RESCUE" }.id || 0,
                                                  status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                                                  technology_id: values_options_for('Technologies', 1).find { |x| x["code"] == "Linux" }.id || 0,
                                                  owner_id: @business_process.owner_id,
                                                  created_by: current_login,
                                                  updated_by: current_login,
                                                  sort_code: "99",
                                                  #success_next_id: ending.id,
                                                  #failure_next_id: ending.id,
                                                  parameters: @business_process.parameters)
    rescuing.name_translations.build(field_name: "name",
                                    language: current_language,
                                    translation: rescuing.name)

    respond_to do |format|
      if @business_process.save
        # Link Start to End
        starting.update_attributes(success_next_id: ending.id, failure_next_id: rescuing.id)
        format.html { redirect_to @business_process, notice: t('BPCreated') } #'Business process was successfully created.'
        format.json { render json: @business_process, status: :created, location: @business_process }
      else
        format.html { render action: "new" }
        format.json { render json: @business_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /business_processes/1
  # PUT /business_processes/1.json
  def update
    ### Retrieved by Callback function
    @business_process.updated_by = current_login
    @business_process.sort_code = @business_process.zone_from&.sort_code
    json_parameters_serialization(@business_process)

    respond_to do |format|
      if @business_process.update_attributes(business_process_params)
        format.html { redirect_to @business_process, notice: t('BPUpdated') } #'Business process was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @business_process.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /business_processs/1
    # Generate production events
  def schedule
    # Create the new job
    @job = ProductionJob.new(playground_id: @business_process.playground_id,
                            business_flow_uuid: @business_process.parent.uuid,
                            business_process_id: @business_process.id,
                            code: @business_process.code,
                            status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                            parameters: @business_process.parameters,
                            owner_id: @business_process.owner_id,
                            created_by: current_user.user_name,
                            updated_by: current_user.user_name)

    # Create job events
    @business_process.activities.order(sort_code: :asc, code: :asc).each do |activity|
      @production_group = @job.production_groups.build(
                            playground_id: @job.playground_id,
                            activity_id: activity.id,
                            code: activity.code,
                            node_type_id: activity.node_type_id,
                            sort_code: activity.sort_code,
                            success_next_id: nil,
                            failure_next_id: nil,
                            status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                            parameters: activity.parameters)

      activity.tasks.order(sort_code: :asc, code: :asc).each do |task|
        # Merge statement
        if !(task.parameters.blank? or task.statement.blank?)
          task.parameters.each do |parameter|
            # Merge the parameter if used in the statement
            if task.statement.index(parameter["name"])
              task.statement.gsub!(parameter["name"], parameter["value"])
            end
          end
        end
        @production_event = @production_group.production_events.build(
                                  playground_id: @job.playground_id,
                                  task_id: task.id,
                                  code: task.code,
                                  node_type_id: task.node_type_id,
                                  sort_code: task.sort_code,
                                  success_next_id: nil,
                                  failure_next_id: nil,
                                  target_object_id: task.target_object_id,
                                  status_id: options_for('Statuses', 'Scheduler').find { |x| x["code"] == "NEW" }.id || 0,
                                  statement: task.statement,
                                  statement_language_id: task.statement_language_id,
                                  parameters: task.parameters,
                                  technology_id: task.technology_id,
                                  return_value_pattern: task.return_value_pattern
                                  )
      end
      @job.save!

      # Assign events links based on tasks links
      @job.production_groups.order(:activity_id, :sort_code).each do |group|
        if group.node_type_id == options_for('node_types', 'Scheduler').find { |x| x["code"] == "END"}.id
          next_success_group = nil
          next_failure_group = nil
        else
          next_success_group = @job.production_groups.where(activity_id: group.activity.success_next_id).take
          next_failure_group = @job.production_groups.where(activity_id: group.activity.failure_next_id).take
        end
        group.update_attributes(success_next_id: next_success_group&.id, failure_next_id: next_failure_group&.id)
        group.production_events.order(:task_id, :sort_code).each do |event|
          if event.node_type_id == options_for('node_types', 'Scheduler').find { |x| x["code"] == "END"}.id
            next_success_event = nil
            next_failure_event = nil
          else
            next_success_event = group.production_events.where(task_id: event.task.success_next_id).take
            next_failure_event = group.production_events.where(task_id: event.task.failure_next_id).take
          end
          event.update_attributes(success_next_id: next_success_event&.id, failure_next_id: next_failure_event&.id)
        end
      end
      # Links activities together
    end
    if @job.save
      redirect_to scheduler_production_jobs_path, notice: t('ProductionJobCreated')
    else
      render action: "edit"
    end
  end

  # POST /business_processs/1
  # POST /business_processs/1.json
  def activate
    ### Retrieved by Callback function
    @business_process.set_as_active(current_login)

    respond_to do |format|
      if @business_process.save
          format.html { redirect_to @business_process, notice: t('BPRecalled') } #'Business process was successfully recalled.'
          format.json { render json: @business_process, status: :created, location: @business_process }
        else
          format.html { redirect_to @business_process, notice: t('BPRecalledKO') } #'Business process  cannot be recalled.'
          format.json { render json: @business_process.errors, status: :unprocessable_entity }
      end
    end
  end

def destroy
  @business_process.set_as_inactive(current_login)
  respond_to do |format|
    format.html { redirect_to business_processes_url, notice: t('BPDeleted') } #'Business process was successfully deleted.'
    format.json { head :no_content }
  end
end


### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business process
    def set_business_process
      @business_process = BusinessProcess.pgnd(current_playground).includes(:owner, :status).find(params[:id])
      @child_activities = @business_process.activities
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@business_process)
    end

    # Generate the statement based on task's template statement, technology, and parameters
    def linked_statement(activity, task)
      ## Manage Start nodes -> upload parameters file, create log file (optional)
      # Dump parameters to file if any
      if activity.node_type.code == 'START' and
        task.node_type.code == 'START' and
        !activity.parameters.blank? and
        !activity.params_file_name.blank?
        if activity.params_file_name.end_with?('json', 'JSON')
          File.write("./public/#{activity.params_file_name}", JSON.dump(activity.parameters))
        else
          CSV.open("./public/#{activity.params_file_name}", "w") do |csv|
            csv << activity.parameters.first.keys
            activity.parameters.each do |hash|
              csv << hash.values
              puts hash.values
            end
          end
        end
        # Upload the parameters file
        statement = "PUSH public/#{activity.params_file_name} #{activity.params_file_path}/#{activity.params_file_name}"
      end

      # Pull back the parameters file if any
      if activity.node_type.code == 'END' and
        task.node_type.code == 'END' and
        !activity.parameters.blank? and
        !activity.params_file_name.blank?
        statement = "PULL #{activity.params_file_path}/#{activity.params_file_name} public/#{activity.params_file_name}"
      end

      # Remove task's log_file if any
      if activity.node_type.code != 'START' and
        task.node_type.code == 'START' and
        !task.log_file_name.blank?
        statement = "[ -e #{task.log_file_path}/#{task.log_file_name} ] && rm #{task.log_file_path}/#{task.log_file_name}"
      end

      # Pull task's log_file if any
      if activity.node_type.code != 'END' and
        task.node_type.code == 'END' and
        !task.log_file_name.blank?
        statement = "PULL #{task.log_file_path}/#{task.log_file_name} public/#{task.log_file_name}"
      end

      statement
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
      Translation.arel_table.alias('tr_extenal_descriptions')
    end

    def processes
      BusinessProcess.arel_table
    end

    def translated_processes
      processes.
      join(owners).on(processes[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(processes[:id].eq(names[:document_id]).and(names[:document_type].eq("BusinessProcess")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(processes[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("BusinessProcess")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join(external_descriptions, Arel::Nodes::OuterJoin).on(processes[:id].eq(external_descriptions[:document_id]).and(external_descriptions[:document_type].eq("BusinessProcess")).and(external_descriptions[:language].eq(current_language).and(external_descriptions[:field_name].eq('external_description')))).
      join_sources
    end

    def index_fields
      [processes[:id], processes[:code], processes[:hierarchy], processes[:name], processes[:description], processes[:status_id], processes[:updated_by], processes[:updated_at], processes[:is_active], processes[:is_current], processes[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
        when not business_processes.is_active then '0'
        when business_processes.is_active and business_processes.is_finalised then '1'
        else '2'
          end").as("calculated_status")]
    end

    def order_by
      [processes[:hierarchy].asc]
    end

  ### strong parameters
  def business_process_params
    params.require(:business_process).permit(:code,
                                            :name,
                                            :status_id,
                                            :pcf_index,
                                            :pcf_reference,
                                            :description,
                                            :organisation_id,
                                            :responsible_id,
                                            :deputy_id,
                                            :participants,
                                            :parameters,
                                            :gsbpm_id,
                                            :zone_from_id,
                                            :zone_to_id,
                                            name_translations_attributes:[:id,
                                                                          :field_name,
                                                                          :language,
                                                                          :translation],
                                            description_translations_attributes:[:id,
                                                                                :field_name,
                                                                                :language,
                                                                                :translation],
                                            external_description_translations_attributes:[:id,
                                                                                :field_name,
                                                                                :language,
                                                                                :translation],
                                            :data_provider_ids => [])
  end

end
