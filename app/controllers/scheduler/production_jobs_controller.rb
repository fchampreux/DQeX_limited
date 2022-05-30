class Scheduler::ProductionJobsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_production_job, only: [ :show, :edit, :update, :destroy ]

  # Initialise breadcrumbs for the resulting view
  before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /production_jobs or /production_jobs.json
  def index
    @production_jobs = ProductionJob.joins(production_jobs).
                                      pgnd(current_playground).
                                      where("business_process_id = ? or ? is null", params[:filter], params[:filter]).
                                      where("business_flows.code in (?)", current_user.preferred_activities).
                                      order(order_by).
                                      select(job_index_fields).
                                      paginate(page: params[:page], :per_page => params[:per_page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @production_jobs }
      format.csv { send_data @production_jobs.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /production_jobs/1 or /production_jobs/1.json
  def show
  end

  # GET /production_jobs/new
  def new
    @production_job = ProductionJob.new
  end

  # GET /production_jobs/1/edit
  def edit
  end

  # POST /production_jobs or /production_jobs.json
  def create
    @production_job = ProductionJob.new(production_job_params)

    respond_to do |format|
      if @production_job.save
        format.html { redirect_to @production_job, notice: "Production job was successfully created." }
        format.json { render :show, status: :created, location: @production_job }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @production_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_jobs/1 or /production_jobs/1.json
  def update
    respond_to do |format|
      if @production_job.update(production_job_params)
        format.html { redirect_to @production_job, notice: "Production job was successfully updated." }
        format.json { render :show, status: :ok, location: @production_job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @production_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_jobs/1 or /production_jobs/1.json
  def destroy
    @production_job.destroy
    respond_to do |format|
      format.html { redirect_to scheduler_production_jobs_path, notice: "Production job was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_job
      @production_job = ProductionJob.joins(production_jobs).
                                      pgnd(current_playground).
                                      select(job_index_fields).
                                      #includes(:owner, :status, :production_events).
                                      find(params[:id])

      @production_groups = @production_job.production_groups.
                                            where(production_execution_id: nil).
                                            order(:sort_code).
                                            paginate(page: params[:page], :per_page => params[:per_page])

      @production_schedules = @production_job.production_schedules.
                                            order(:next_run).
                                            paginate(page: params[:page], :per_page => params[:per_page])

      @production_executions = @production_job.production_executions.
                                            order(:started_at).
                                            paginate(page: params[:page], :per_page => params[:per_page])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@production_job.parent)
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

    def flows
      BusinessFlow.arel_table
    end

    def areas
      BusinessArea.arel_table
    end

    def playgrounds
      Playground.arel_table
    end

    def parameters
      Parameter.arel_table
    end

    # job index
    def production_jobs
      jobs.
      join(owners).on(jobs[:owner_id].eq(owners[:id])).
      join(processes).on(jobs[:business_process_id].eq(processes[:id])).
      join(process_names, Arel::Nodes::OuterJoin).on(processes[:id].eq(process_names[:document_id]).and(process_names[:document_type].eq("BusinessProcess")).and(process_names[:language].eq(current_language).and(process_names[:field_name].eq('name')))).
      join(flows).on(processes[:business_flow_id].eq(flows[:id])).
      join(flow_names, Arel::Nodes::OuterJoin).on(flows[:id].eq(flow_names[:document_id]).and(flow_names[:document_type].eq("BusinessFlow")).and(flow_names[:language].eq(current_language).and(flow_names[:field_name].eq('name')))).
      join(areas).on(flows[:business_area_id].eq(areas[:id])).
      join(area_names, Arel::Nodes::OuterJoin).on(areas[:id].eq(area_names[:document_id]).and(area_names[:document_type].eq("BusinessArea")).and(area_names[:language].eq(current_language).and(area_names[:field_name].eq('name')))).
      join(playgrounds).on(areas[:playground_id].eq(playgrounds[:id])).
      join(playground_names, Arel::Nodes::OuterJoin).on(playgrounds[:id].eq(playground_names[:document_id]).and(playground_names[:document_type].eq("Playground")).and(playground_names[:language].eq(current_language).and(playground_names[:field_name].eq('name')))).
      join(parameters).on(jobs[:status_id].eq(parameters[:id])).
      join_sources
    end

    def job_index_fields
      [jobs[:id],
        jobs[:code].as("job_code"),
        jobs[:status_id],
        jobs[:created_at],
        jobs[:updated_by],
        jobs[:updated_at],
        jobs[:business_process_id],
        jobs[:parameters],
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
        owners[:name].as("owner_name"),
        parameters[:property].as("status_icon_id")]
    end

    def order_by
      [jobs[:code], jobs[:updated_at].desc]
    end

    # Job selection filters
    def playgrounds_list
      playgrounds.join(playground_names, Arel::Nodes::OuterJoin).on(playgrounds[:id].eq(playground_names[:document_id]).and(playground_names[:document_type].eq("Playground")).and(playground_names[:language].eq(current_language).and(playground_names[:field_name].eq('name')))).
      where(playgrounds[:id].gt(1)).
      join_sources
    end

    def business_areas_list
      areas.join(area_names, Arel::Nodes::OuterJoin).on(areas[:id].eq(area_names[:document_id]).and(area_names[:document_type].eq("BusinessArea")).and(area_names[:language].eq(current_language).and(area_names[:field_name].eq('name')))).
      where(areas[:id].gt(1)).
      join_sources
    end

    def business_flows_list
      flows.join(flow_names, Arel::Nodes::OuterJoin).on(flows[:id].eq(flow_names[:document_id]).and(flow_names[:document_type].eq("BusinessFlow")).and(flow_names[:language].eq(current_language).and(flow_names[:field_name].eq('name')))).
      where(flows[:id].gt(1)).
      join_sources
    end

    def playgrounds_index
      [playgrounds[:id], playgrounds[:name], playground_names[:translation].as("playground_name")]
    end

    def business_areas_index
      [areas[:id], areas[:name], areas[:playground_id], area_names[:translation].as("area_name")]
    end

    def business_flows_index
      [flows[:id], flows[:name], flows[:business_area_id], flow_names[:translation].as("flow_name")]
    end

    # Only allow a list of trusted parameters through.
    def production_job_params
      params.fetch(:production_job, {})
    end
end
