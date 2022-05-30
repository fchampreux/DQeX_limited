class Scheduler::ProductionSchedulesController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_production_schedule, only: %i[ show edit update destroy run_once release suspend ]

  # GET /production_schedules or /production_schedules.json
  def index
    @production_schedules = ProductionSchedule.joins(production_schedules).pgnd(current_playground).
      select(index_fields).order(order_by).
      paginate(page: params[:page], :per_page => params[:per_page])
  end

  # GET /production_schedules/1 or /production_schedules/1.json
  def show
    redirect_to scheduler_production_schedules_path
  end

  # GET /production_schedules/new
  def new
    @production_job = ProductionJob.find(params[:production_job_id])
    @production_schedule = ProductionSchedule.new(mode_id: options_for('schedule_modes').find { |x| x["code"] == "TEST" }.id || 0,
                                                  parameters: @production_job.parameters )
    render layout: false
  end

  # GET /production_schedules/1/edit
  def edit
    render layout: false
  end

  # POST /production_schedules or /production_schedules.json
  def create
    @production_job = ProductionJob.find(params[:production_job_id])
    @production_schedule = @production_job.production_schedules.build(production_schedule_params)
    metadata_setup(@production_schedule)
    json_parameters_serialization(@production_schedule)
    if @production_schedule.mode.code == 'TEST' or @production_schedule.mode.code == 'MESSAGE'
      @production_schedule.next_run = nil
    end

    respond_to do |format|
      if @production_schedule.save
        format.html { redirect_to scheduler_production_job_path(@production_job), notice: "Production schedule was successfully created." }
        format.json { render :show, status: :created, location: @production_schedule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @production_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_schedules/1 or /production_schedules/1.json
  def update
    @production_job = ProductionJob.find(@production_schedule.production_job_id)
    Rails.logger.interactions.info "Schedule update - id: #{@production_schedule.id},
                                    code: #{@production_schedule.code},
                                    mode: #{@production_schedule.mode.code}"
    if @production_schedule.mode.code == 'TEST' or @production_schedule.mode.code == 'MESSAGE'
      @production_schedule.next_run = nil
    end
    respond_to do |format|
      if @production_schedule.update(production_schedule_params)
        json_parameters_serialization(@production_schedule)
        @production_schedule.update_attribute(:status_id, statuses.find { |x| x["code"] == "READY" }.id || 0)
        format.html { redirect_to scheduler_production_job_path(@production_job), notice: "Production schedule was successfully updated." }
        format.json { render :show, status: :ok, location: @production_schedule }
      else
        @production_schedule.update_attribute(:status_id, statuses.find { |x| x["code"] == "INACTIVE" }.id || 0)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @production_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_schedules/1 or /production_schedules/1.json
  def destroy
    @job = @production_schedule.parent
    @production_schedule.destroy
    respond_to do |format|
      format.html { redirect_to scheduler_production_job_path(id: @job.id), notice: "Production schedule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def run_once
    ### How it works
    # A job schedule creates an execution instance each time it is invoked
    # The execution instance is a duplicate of job's groups and events
    # The Run RunOnce option allows manual execution triggering
    # The helper returns an @execution_instance

    @execution = new_execution_instance(@production_schedule.id)
    execute_production_groups @execution
    #Scheduler::ScriptWorker.perform_async(@production_schedule.id)
    redirect_to scheduler_production_job_path(@production_schedule.parent)
  end

  def release
    @production_schedule.update_attribute(:status_id, statuses.find { |x| x["code"] == "READY" }.id)
    respond_to do |format|
      format.html { redirect_to scheduler_production_job_path(@production_schedule.parent), notice: "Production schedule was successfully released." }
      format.json { head :no_content }
    end
  end

  def suspend
    @production_schedule.update_attribute(:status_id, statuses.find { |x| x["code"] == "INACTIVE" }.id)
    respond_to do |format|
      format.html { redirect_to scheduler_production_job_path(@production_schedule.parent), notice: "Production schedule was successfully suspended." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_schedule
      @production_schedule = ProductionSchedule.pgnd(current_playground).includes(:owner, :status).find(params[:id])
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

    def jobs
      ProductionJob.arel_table
    end

    def schedules
      ProductionSchedule.arel_table
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

    def production_schedules
      schedules.
      join(owners).on(schedules[:owner_id].eq(owners[:id])).
      join(jobs).on(schedules[:production_job_id].eq(jobs[:id])).
      join(processes).on(jobs[:business_process_id].eq(processes[:id])).
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
      [schedules[:id],
        schedules[:code].as("schedule_code"),
        schedules[:status_id],
        schedules[:parameters],
        schedules[:active_from],
        schedules[:active_to],
        schedules[:environment_id],
        schedules[:mode_id],
        schedules[:average_duration],
        schedules[:last_run],
        schedules[:next_run],
        jobs[:created_at],
        jobs[:updated_by],
        jobs[:updated_at],
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
      [playgrounds[:code].asc, areas[:code].asc, flows[:code].asc, processes[:code].asc, schedules[:code].asc]
    end

    # Only allow a list of trusted parameters through.
    def production_schedule_params
      params.require(:production_schedule).permit(:id,
                                                  :playground_id,
                                                  :environment_id,
                                                  :active_from,
                                                  :active_to,
                                                  :repeat_value,
                                                  :repeat_interval,
                                                  :repeat_interval_unit_id,
                                                  :repeat_counter,
                                                  :next_run,
                                                  :run_on_nth,
                                                  :run_on_day_id,
                                                  :period_type_id,
                                                  :within_period_id,
                                                  :queue_name,
                                                  :queue_exchange,
                                                  :queue_key,
                                                  :queue_payload,
                                                  :message_identifier,
                                                  :mode_id,
                                                  :status_id,
                                                  :code,
                                                  :parameters)
      #params.fetch(:production_schedule, {})
    end
end
