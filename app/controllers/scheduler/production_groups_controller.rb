class Scheduler::ProductionGroupsController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_production_group, except: [:create, :new, :index]

  # GET /production_groups or /production_groups.json
  def index
    @production_groups = ProductionGroup.all
  end

  # GET /production_groups/1 or /production_groups/1.json
  def show
    # Display in modal window
    render layout: false
  end

  # GET /production_groups/1/analyse or /production_groups/1/analyse.json
  def analyse
    # Display in modal window
    render layout: false
  end

  # GET /production_groups/new
  def new
    @production_group = ProductionGroup.new
  end

  # GET /production_groups/1/edit
  def edit
  end

  # POST /production_groups or /production_groups.json
  def create
    @production_group = ProductionGroup.new(production_group_params)

    respond_to do |format|
      if @production_group.save
        format.html { redirect_to @production_group, notice: "Production group was successfully created." }
        format.json { render :show, status: :created, location: @production_group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @production_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_groups/1 or /production_groups/1.json
  def update
    respond_to do |format|
      if @production_group.update(production_group_params)
        format.html { redirect_to @production_group, notice: "Production group was successfully updated." }
        format.json { render :show, status: :ok, location: @production_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @production_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_groups/1 or /production_groups/1.json
  def destroy
    @production_group.destroy
    respond_to do |format|
      format.html { redirect_to production_groups_url, notice: "Production group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /production_groups/1/trigger
  def trigger
    ### Retrieved by Callback function
    execute_group_events(@production_group, ProductionGroup.new, ProductionEvent.new)

    respond_to do |format|
      format.html { redirect_back fallback_location: @production_group, notice: @msg }
      format.js
    end
  end

=begin # Former script
    if production_group_params[:statement].split[0].upcase == 'UPLOAD'
      Rails.logger.ssh.info "---SSH request: #{production_group_params[:statement]}"
      output = Net::SCP.start(remote_host, remote_user, password: remote_password) do |scp|
        scp.upload!(production_group_params[:statement].split[1], production_group_params[:statement].split[2])
      end
      output = output ? 'true' : 'false'
    else
      Net::SSH.start(remote_host, remote_user, password: remote_password) do |ssh|
        Rails.logger.ssh.info "---SSH request: #{production_group_params[:statement]}"
        output = ssh.exec!("#{production_group_params[:statement]}")
      end
    end
    Rails.logger.ssh.info "---SSH output: #{output}"
    if output.upcase.index('ERROR') or output.upcase.index('NO')
      @production_group.update_attributes(:error_message, output)
      @msg = t('GitHashError')
    else
      @production_group.update_attribute(:return_value, output)
      @msg = t('ActionUpdated')
    end
    #render js: "document.getElementById('production_group-git-hash').value = ('#{ @production_group.git_hash }');"

    respond_to do |format|
      format.html { redirect_back fallback_location: @production_group, notice: @msg }
      format.js
    end

  end

=end

  def get_children
    puts '###################### Params ######################'
    print 'id : '
    puts params[:id]
    @production_group = ProductionGroup.find(params[:id])
    @production_events = ProductionEvent.where(production_group_id: params[:id]).order(started_at: :desc, sort_code: :asc)
    puts @production_events

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @production_events }
      format.js # uses specific template to handle js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_group
      @production_group = ProductionGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def production_group_params
      params.fetch(:production_group, {})
    end
end
