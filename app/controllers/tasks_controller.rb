class TasksController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.joins(translated_tasks).visible.
      select(index_fields).order(order_by)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
      format.csv { send_data @tasks.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /tasks
  # GET /tasks.json
  def index_short
    @tasks = Task.joins(translated_tasks).owned_by(current_user).
      select(index_fields).order(order_by)

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @tasks }
      format.csv { send_data @tasks.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    ### Retrieved by Callback function
    render layout: false
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @parent = params[:parent_class].constantize.find(params[:parent_id])
    @task = @parent.tasks.build(status_id: (statuses.find { |x| x["code"] == "NEW" }.id || 0),
                                playground_id: @parent.playground_id,
                                responsible_id: @parent.responsible_id,
                                deputy_id: @parent.deputy_id,
                                node_type_id: options_for('Node_types', 'Scheduler').find { |x| x["code"] == "PROCESS" }.id || 0,
                                technology_id: @parent.technology_id)
    @task.parameters = @parent.parameters if @parent.has_attribute?(:parameters)

    # Create a translation for each configured language
    list_of_languages.each do |locution|
      @task.name_translations.build(field_name: 'name', language: locution.property)
      @task.description_translations.build(field_name: 'description', language: locution.property)
    end
    render layout: false
  end

  # GET /tasks/1/edit
  def edit
    ### Retrieved by Callback function
    # Generate missing translations
    check_translations(@task)
    render layout: false
  end

  # POST /tasks
  # POST /tasks.json
  def create
    puts params
    @parent = task_params[:parent_type].constantize.find(task_params[:parent_id])
    @task = @parent.tasks.build(task_params)
    metadata_setup(@task)
    @task.sort_code = Parameter.find(task_params[:node_type_id]).property
    json_parameters_serialization(@task)

    respond_to do |format|
      if @task.save
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Task was successfully created.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@task.errors.full_messages.join(',')}" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    ### Retrieved by Callback function
    @task.updated_by = current_login
    @task.sort_code = Parameter.find(task_params[:node_type_id]).property
    json_parameters_serialization(@task)

    respond_to do |format|
      if @task.update_attributes(task_params)
        format.html { redirect_back fallback_location: root_path, notice: t('.Success') } #'Task was successfully created.'
        format.json { head :no_content }
      else
        format.html { redirect_back fallback_location: root_path, notice: "#{t('.Failure')}: #{@task.errors.full_messages.join(',')}" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /tasks/1/verify
  def verify
    ### Retrieved by Callback function
    remote_system = Value.find(task_params[:technology_id])
    # remote_system = Value.find(task_params[:technology_id])
    remote_host = remote_system.uri
    #remote_login = remote_system.annotations.where("annotation_type_id = ?", helpers.annotation_types.find { |x| x["code"] == "LOGIN" }.id ).take
    remote_login = remote_system.annotations.where(code: 'LOGIN').take # Both ways of doing it work fine.
    remote_user = remote_login.name
    remote_password = remote_login.uri

    Rails.logger.ssh.info "---Start SSH connection"
    Rails.logger.ssh.info "--- ssh #{remote_user}@#{remote_host}"
    puts "------------ ssh #{remote_user}@#{remote_host} ------------"
    Net::SSH.start(remote_host, remote_user, password: remote_password) do |session|
      session.open_channel do |channel|
        channel.request_pty do |ch, success|
          raise "Error requesting pty" unless success
          puts "------------ pty successfully obtained"
        end

        Rails.logger.ssh.info "------------ statement: sh get-git.sh"
        channel.exec "sh get-git.sh" do |ch, success|
          abort "could not execute command" unless success

          channel.on_data do |ch, data|
            Rails.logger.ssh.info "---SSH output: #{data}"
            puts "------------ got stdout: #{data}"
            @task.update_attribute(:git_hash, data)
          end

          channel.on_extended_data do |ch, type, data|
            puts "------------ got stderr: #{data}"
          end

          channel.on_close do |ch|
            puts "------------ channel is closing!"
            Rails.logger.ssh.info "---Close SSH connection \n"
          end

        end
      end
      session.loop
    end
    #render js: "document.getElementById('task-git-hash').value = ('#{ @task.git_hash }');"

    respond_to do |format|
      format.html { redirect_back fallback_location: @task, notice: @msg }
      format.js
    end

  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    ### Retrieved by Callback function
    @task.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: t('.Success') } # 'Task was successfully deleted.'
      format.json { head :no_content }
    end
  end

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current business flow
    def set_Task
      @task = Task.pgnd(current_playground).includes(:owner, :status, :parent).find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@task)
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

    def tasks
      Task.arel_table
    end

    def translated_tasks
      tasks.
      join(owners).on(tasks[:owner_id].eq(owners[:id])).
      join(names, Arel::Nodes::OuterJoin).on(tasks[:id].eq(names[:document_id]).and(names[:document_type].eq("Task")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(tasks[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Task")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [tasks[:id], tasks[:code], tasks[:hierarchy], tasks[:name], tasks[:description], tasks[:status_id], tasks[:updated_by], tasks[:updated_at], tasks[:is_active], tasks[:is_current], tasks[:is_finalised],
        owners[:name].as("owner_name"),
        names[:translation].as("translated_name"),
        descriptions[:translation].as("translated_description"),
        Arel::Nodes::SqlLiteral.new("case
          when not tasks.is_active then '0'
          else '1'
          end").as("calculated_status")]
    end

    def order_by
      [tasks[:hierarchy].asc]
    end

  ### strong parameters
  def task_params
    params.require(:task).permit(:code,
                                :name,
                                :description,
                                :parent_id,
                                :parent_type,
                                :status_id,
                                :node_type_id,
                                :task_type_id,
                                :statement,
                                :statement_language_id,
                                :script_name,
                                :script_path,
                                :script_language_id,
                                :log_file_name,
                                :log_file_path,
                                :success_next_id,
                                :failure_next_id,
                                :is_synchro,
                                :is_template,
                                :template_id,
                                :technology_id,
                                :target_object_id,
                                :git_hash,
                                :parameters,
                                :return_value_pattern,
                                :node_type_id,
                                :verify_on_technology_id,
                                name_translations_attributes:[:id,
                                                              :field_name,
                                                              :language,
                                                              :translation],
                                description_translations_attributes:[:id,
                                                                    :field_name,
                                                                    :language,
                                                                    :translation])
  end

end
