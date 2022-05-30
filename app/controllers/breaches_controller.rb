class BreachesController < ApplicationController
# Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current breach
  before_action :set_breach, only: [:show, :edit, :update, :destroy]

# Create the selection lists be used in the form
  before_action :set_responsibles_list, only: [:new, :edit, :update, :create]
  before_action :set_approvers_list, only: [:new, :edit, :update, :create]
  before_action :set_breach_statuses_list, only: [:new, :edit, :update, :create]

  # GET /breaches
  # GET /breaches.json
  def index
    @breaches = Breach.pgnd(current_playground).order("created_at DESC").paginate(page: params[:page], :per_page => paginate_lines)
  end

  # GET /breaches/1
  # GET /breaches/1.json
  def show
  end

  # GET /breaches/new
  def new
    @business_rule = BusinessRule.find(params[:business_rule_id])
    @breach = Breach.new()
  end

  # GET /breaches/1/edit
  def edit
    @business_rule = @breach.business_rule
  end

  # POST /breaches
  # POST /breaches.json
  def create
    @breach = Breach.new(breach_params)
    metadata_setup(@breach)

    respond_to do |format|
      if @breach.save
        format.html { redirect_to @breach, notice: t('RequestCreated') } #'Request was successfully created.'
        format.json { render action: 'show', status: :created, location: @breach }
      else
        format.html { render action: 'new' }
        format.json { render json: @breach.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /breaches/1
  # PATCH/PUT /breaches/1.json
  def update
    respond_to do |format|
      if @breach.update(breach_params)
        format.html { redirect_to @breach, notice: t('RequestUpdated') } #'Request was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @breach.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /breaches/1
  # DELETE /breaches/1.json
  def destroy
    @breach.destroy
    respond_to do |format|
      format.html { redirect_to breaches_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_breach
      @breach = Breach.pgnd(current_playground).find(params[:id])
    end

  ### before filters


    # Never trust parameters from the scary internet, only allow the white list through.
    def breach_params
      params.require(:breach).permit(:breach_type_id, :description)
    end
  end
