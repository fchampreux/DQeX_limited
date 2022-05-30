class Governance::NotificationsController < GovernanceController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

# Retrieve current notification
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

# Create the selection lists be used in the form
  before_action :set_users_list, only: [:new, :edit, :update, :create]
  #before_action :set_notification_statuses_list, only: [:new, :edit, :update, :create]
  before_action :set_severity_list, only: [:new, :edit, :update, :create]

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.joins(translated_notifications).
                                  pgnd(current_playground).
                                  where("notifications.responsible_id = ? or ? is null", params[:owner], params[:owner]).
                                  visible.
                                  search(params[:criteria]).
                                  select(index_fields).
                                  order(order_by).
                                  paginate(page: params[:page], :per_page => paginate_lines)

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @notifications }
    end
  end
  
  # GET /notifications/1
  # GET /notifications/1.json
  def show
    if @notification.workflow_state == 'new'
      @notification.open!
      @notification.update_attribute(:status_id, statuses.find { |x| x["code"] == "VIEWED" }.id || 0 )
    end
  end

  # GET /notifications/new
  def new
    topic = params[:topic_type].constantize.find(params[:topic_id])
    topic.reject!
    topic.update_attribute(:status_id, statuses.find { |x| x["code"] == "REJECTED" }.id || 0)
    @playground = Playground.find(current_playground)
    @notification = @playground.notifications.build( playground_id:   	params[:playground_id],
                                      description:   		params[:description],
                                      severity_id:   		params[:severity_id],
                                      status_id:   			params[:status_id],
                                      expected_at:   		params[:expected_at],
                                      responsible_id:   params[:responsible_id],
                                      owner_id:   			params[:owner_id],
                                      created_by:   		params[:created_by],
                                      updated_by:  			params[:updated_by],
                                      topic_type:   		params[:topic_type],
                                      topic_id:   			params[:topic_id],
                                      deputy_id:   			params[:deputy_id],
                                      organisation_id:  params[:organisation_id],
                                      code:   			   	params[:code],
                                      name:  				    params[:name])
    @notification.name_translations.build(field_name: 'name', language: current_language, translation: "#{t(params[:topic_type])} #{params[:code]} #{params[:name]}")
    @notification.description_translations.build(field_name: 'description', language: current_language, translation: "#{format_datetime(Time.now)} #{current_user.name} :\n> #{t(params[:topic_type])} #{t('Rejected')}")
    render layout: false
  end

  # GET /notifications/1/edit
  def edit
    check_translations(@notification)
    current_text = translation_for(@notification.description_translations)
    @notification.description_translations.update_all(translation: "#{current_text}\n#{format_datetime(Time.now)} #{current_user.name} :\n>")
  end

  # GET /notifications/1/edit
  def edit_description
    render layout: false
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)
    metadata_setup(@notification)

    respond_to do |format|
      if @notification.save
        format.html { redirect_back fallback_location: root_path, notice: t('NotCreated') } #'Notification was successfully created.'
        format.json { render action: 'show', status: :created, location: @notification }
      else
        format.html { render action: 'new' }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to [:governance, @notification], notice: t('NotUpdated') } #'Notification was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.pgnd(current_playground).find(params[:id])
    end

    ### queries tayloring
    def owners
      User.arel_table.alias('owners')
    end

    def responsibles
      User.arel_table.alias('responsibles')
    end

    def owners_groups
      GroupsUser.arel_table.alias('owners_groups')
    end

    def responsibles_groups
      GroupsUser.arel_table.alias('responsibles_groups')
    end

    def notifications
      Notification.arel_table
    end

    def names
      Translation.arel_table.alias('tr_names')
    end

    def descriptions
      Translation.arel_table.alias('tr_descriptions')
    end

    def states
      Parameter.arel_table.alias('states')
    end

    def states_names
      Translation.arel_table.alias('states_names')
    end

    def impacts
      Parameter.arel_table.alias('impacts')
    end

    def impacts_names
      Translation.arel_table.alias('impacts_names')
    end

    def classes
      Parameter.arel_table.alias('classes')
    end

    def classes_names
      Translation.arel_table.alias('classes_names')
    end

    def translated_notifications
      notifications.
      join(owners).on(notifications[:owner_id].eq(owners[:id])).                                       # Idenfify the owner to display its name in the index (notification sender)
      join(owners_groups).on(notifications[:owner_id].eq(owners_groups[:user_id])).                    # Identify his group
      join(responsibles).on(notifications[:responsible_id].eq(responsibles[:id])).                     # Idenfify the responsible to display its name in the index (notification receiver)
      join(responsibles_groups).on(notifications[:responsible_id].eq(responsibles_groups[:user_id])).  # Identify his group
      join(names, Arel::Nodes::OuterJoin).on(notifications[:id].eq(names[:document_id]).and(names[:document_type].eq("Notification")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(notifications[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("Notification")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      #join(states).on(notifications[:status_id].eq(states[:id])).
      join(states_names, Arel::Nodes::OuterJoin).on(notifications[:status_id].eq(states_names[:document_id]).and(states_names[:document_type].eq("Parameter")).and(states_names[:language].eq(current_language).and(states_names[:field_name].eq('name')))).
      #join(impacts).on(notifications[:severity_id].eq(impacts[:id])).
      join(impacts_names, Arel::Nodes::OuterJoin).on(notifications[:severity_id].eq(impacts_names[:document_id]).and(impacts_names[:document_type].eq("Parameter")).and(impacts_names[:language].eq(current_language).and(impacts_names[:field_name].eq('name')))).
      join(classes, Arel::Nodes::OuterJoin).on(notifications[:topic_type].eq(classes[:code])).
      join(classes_names).on(classes[:id].eq(classes_names[:document_id]).and(classes_names[:document_type].eq("Parameter")).and(classes_names[:language].eq(current_language).and(classes_names[:field_name].eq('name')))).
      join_sources
    end

    def index_fields
      [notifications[:id], notifications[:is_active], notifications[:code], notifications[:name],
      notifications[:created_by], notifications[:updated_by], notifications[:created_at], notifications[:updated_at], notifications[:expected_at], notifications[:closed_at],
      notifications[:topic_type], notifications[:topic_id], notifications[:status_id],  notifications[:severity_id], notifications[:responsible_id], notifications[:owner_id],
        owners[:name].as("owner_name"),
        owners_groups[:group_id].as("owner_group_id"),
        responsibles[:name].as("responsible_name"),
        responsibles_groups[:group_id].as("responsible_group_id"),
        states_names[:translation].as("translated_status"),
        impacts_names[:translation].as("translated_impact"),
        classes_names[:translation].as("translated_class")]
    end

    def order_by
      [notifications[:updated_at].desc]
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:playground_id, :code, :name, :description, :created_by, :updated_by,
                                           :owner_id, :severity_id, :scope_id, :topic_id, :topic_type, :organisation_id,
                                           :expected_at, :closed_at, :responsible_id, :deputy_id, :status_id,
                                       name_translations_attributes:[:id, :field_name, :language, :translation, :_destroy],
                                       description_translations_attributes:[:id, :field_name, :language, :translation, :_destroy])
    end
end
