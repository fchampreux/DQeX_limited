class Scheduler::ProductionExecutionsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_production_execution, except: [:create, :new, :index]

  # GET /production_executions or /production_executions.json
  def index
    @production_executions = ProductionExecution.joins(production_executions).pgnd(current_playground).
      select(index_fields).order(order_by)
  end

  # GET /production_executions/1 or /production_executions/1.json
  def show
  end

  # GET /production_executions/1/analyse or /production_events/1/analyse.json
  def analyse
    # Display in modal window
    render layout: false
  end

  # GET /production_executions/new
  def new
    @production_execution = ProductionExecution.new
  end

  # GET /production_executions/1/edit
  def edit
  end

  # POST /production_executions or /production_executions.json
  def create
    @production_execution = ProductionExecution.new(production_execution_params)

    respond_to do |format|
      if @production_execution.save
        format.html { redirect_to @production_execution, notice: "Production execution was successfully created." }
        format.json { render :show, status: :created, location: @production_execution }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @production_execution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_executions/1 or /production_executions/1.json
  def update
    respond_to do |format|
      if @production_execution.update(production_execution_params)
        format.html { redirect_to @production_execution, notice: "Production execution was successfully updated." }
        format.json { render :show, status: :ok, location: @production_execution }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @production_execution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_executions/1 or /production_executions/1.json
  def destroy
    @production_job = @production_execution.parent
    @production_execution.destroy
    respond_to do |format|
      format.html { redirect_to scheduler_production_job_path(@production_job), notice: "Production execution was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /production_executions/1/execute
  def execute
    execute_production_groups @production_execution

    respond_to do |format|
      format.html { redirect_back fallback_location: @production_execution, notice: @msg }
      format.js
    end
  end

  def get_children
    puts '###################### Params ######################'
    print 'id : '
    puts params[:id]
    @production_groups = ProductionGroup.where(production_execution_id: params[:id]).order(started_at: :desc, sort_code: :asc)

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @production_groups }
      format.js # uses specific template to handle js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_execution
      @production_execution = ProductionExecution.pgnd(current_playground).includes(:owner, :status).find(params[:id])
    end

    ### queries tayloring
    def owners
      User.arel_table.alias('owners')
    end

    def process_names
      Translation.arel_table.alias('process_names')
    end

    def flow_names
      Translation.arel_table.alias('flow_names')
    end

    def area_names
      Translation.arel_table.alias('area_names')
    end

    def playground_names
      Translation.arel_table.alias('playground_names')
    end

    def processes
      BusinessProcess.arel_table
    end

    def executions
      ProductionExecution.arel_table
    end

    def flows
      BusinessFlow.arel_table
    end

    def areas
      BusinessArea.arel_table
    end

    def playgrounds
      Playground.arel_table
    end

    def production_executions
      executions.
      join(owners).on(executions[:owner_id].eq(owners[:id])).
      join(processes).on(executions[:business_process_id].eq(processes[:id])).
      join(process_names, Arel::Nodes::OuterJoin).on(processes[:id].eq(process_names[:document_id]).and(process_names[:document_type].eq("BusinessProcess")).and(process_names[:language].eq(current_language).and(process_names[:field_name].eq('name')))).
      join(flows).on(processes[:business_flow_id].eq(flows[:id])).
      join(flow_names, Arel::Nodes::OuterJoin).on(flows[:id].eq(flow_names[:document_id]).and(flow_names[:document_type].eq("BusinessFlow")).and(flow_names[:language].eq(current_language).and(flow_names[:field_name].eq('name')))).
      join(areas).on(flows[:business_area_id].eq(areas[:id])).
      join(area_names, Arel::Nodes::OuterJoin).on(areas[:id].eq(area_names[:document_id]).and(area_names[:document_type].eq("BusinessArea")).and(area_names[:language].eq(current_language).and(area_names[:field_name].eq('name')))).
      join(playgrounds).on(areas[:playground_id].eq(playgrounds[:id])).
      join(playground_names, Arel::Nodes::OuterJoin).on(playgrounds[:id].eq(playground_names[:document_id]).and(playground_names[:document_type].eq("Playground")).and(playground_names[:language].eq(current_language).and(playground_names[:field_name].eq('name')))).
      join_sources
    end

    def index_fields
      [executions[:id],
        executions[:code].as("execution_code"),
        executions[:status_id],
        executions[:created_at],
        executions[:updated_by],
        executions[:updated_at],
        processes[:code].as("process_code"),
        process_names[:translation].as("production_flow"),
        flow_names[:translation].as("statistical_activity"),
        flows[:code].as("statistical_activity_code"),
        flows[:uuid].as("statistical_activity_uuid"),
        area_names[:translation].as("information_field"),
        areas[:code].as("information_field_code"),
        areas[:uuid].as("information_field_uuid"),
        playground_names[:translation].as("statistical_theme"),
        playgrounds[:code].as("statistical_theme_code"),
        #playgrounds[:uuid].as("statistical_theme_uuid"),
        owners[:name].as("owner_name")]
    end

    def order_by
      [playgrounds[:code].asc, areas[:code].asc, flows[:code].asc, processes[:code].asc, executions[:code].asc]
    end

    # Only allow a list of trusted parameters through.
    def production_execution_params
      params.fetch(:production_execution, {})
    end
end
