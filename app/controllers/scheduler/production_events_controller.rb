class Scheduler::ProductionEventsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_production_event, only: %i[ show edit update destroy trigger analyse ]

  # GET /production_events or /production_events.json
  def index
    @production_events = ProductionEvent.all
  end

  # GET /production_events/1 or /production_events/1.json
  def show
    # Display in modal window
    render layout: false
  end

  # GET /production_events/1/analyse or /production_events/1/analyse.json
  def analyse
    # Display in modal window
    render layout: false
  end

  # GET /production_events/new
  def new
    @production_event = ProductionEvent.new
  end

  # GET /production_events/1/edit
  def edit
  end

  # POST /production_events or /production_events.json
  def create
    @production_event = ProductionEvent.new(production_event_params)

    respond_to do |format|
      if @production_event.save
        format.html { redirect_to @production_event, notice: "Production event was successfully created." }
        format.json { render :show, status: :created, location: @production_event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @production_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_events/1 or /production_events/1.json
  def update
    respond_to do |format|
      if @production_event.update(production_event_params)
        format.html { redirect_to @production_event, notice: "Production event was successfully updated." }
        format.json { render :show, status: :ok, location: @production_event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @production_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_events/1 or /production_events/1.json
  def destroy
    @production_event.destroy
    respond_to do |format|
      format.html { redirect_to production_events_url, notice: "Production event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /production_events/1/trigger
  def trigger
    ### Retrieved by Callback function
    # Update the event with form content.
    @production_event.update_attributes(statement: production_event_params[:statement], technology_id: production_event_params[:technology_id])

    # If rescue event, execute statement, then restart the production group from "predecessor" event
    execute_ssh(@production_event, @production_event.predecessor, @production_event.execution_sequence)
    if @production_event.node_type_id == parameters_for('node_types').find { |x| x["code"] == "RESCUE" }.id
      group = @production_event.parent
      predecessor_group = group.predecessor || ProductionGroup.new
      ### SHOULD RUN FROM EXECUTION LEVEL !!!
      execute_group_events(group, predecessor_group, @production_event.predecessor, group.execution_sequence)
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: @production_event, notice: @msg }
      format.js
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_event
      @production_event = ProductionEvent.find(params[:id])
    end

    ### strong parameters
    def production_event_params
      params.require(:production_event).permit(:id,
                                              :target_object_id,
                                              :task_id,
                                              :status_id,
                                              :started_at,
                                              :reported_at,
                                              :ended_at,
                                              :source_records_count,
                                              :processed_count,
                                              :created,
                                              :read,
                                              :updated,
                                              :deleted,
                                              :rejected,
                                              :error_count,
                                              :error_message,
                                              :technology_id,
                                              :execution_sequence,
                                              :statement,
                                              :return_value,
                                              :success_next_id,
                                              :failure_next_id,
                                              :return_value_pattern,
                                              :completion_message,
                                              :statement_language_id,
                                              :git_hash,
                                              :git_response,
                                              :node_type_id,
                                              :sort_code,
                                              :parameters,
                                              :production_group_id,
                                              :production_execution_id,
                                              :predecessor_id)
    end
end
