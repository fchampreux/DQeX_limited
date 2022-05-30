class Administration::UsersController < AdministrationController
# Check for active session as administrator
  before_action :authenticate_user! # unless ->{:action == 'set_external_reference'}
  load_and_authorize_resource # except: :set_external_reference

#  before_action :signed_as_admin
  before_action :set_users_list, only: [:new, :edit, :update, :create]

# Retrieve current user
  before_action :set_user, only: [:show, :edit, :update, :destroy, :pass, :set_playground, :activate]

  # Initialise breadcrumbs for the resulting view
  #before_action :set_breadcrumbs, only: [:show, :edit, :update]

  # GET /users
  # GET /users.json
  def index
    @users = User.joins(translated_users).
                  where("users.owner_id = ? or ? is null", params[:owner], params[:owner]).
                  visible.
                  select(index_fields).
                  order(order_by)

    respond_to do |format|
      format.html { render :index } # index.html.erb
      format.json { render json: @users }
      format.csv { send_data @users.to_csv }
      format.xlsx # uses specific template to render xml
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    ### Retrieved by Callback function

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end


  # Get /users/export.xlsx
  def export
    @users = User.joins(translated_users).visible.
      select(index_fields).order(order_by)
    ### Exports the parameters attached to @userss in a Workbook
    workbook = WriteXLSX.new("./public/users_export.xlsx")
    title = workbook.add_format(:font  => 'Calibri', :size  => 16, :color => 'blue', :bold  => 1)
    header = workbook.add_format(:font  => 'Calibri', :size  => 12, :color => 'black', :bold  => 1)
    data = workbook.add_format(:font  => 'Calibri', :size  => 10, :color => 'black', :bold  => 0)
    workbook.set_properties(
    :title    => "Users lists export: #{$Organisation}",
    :subject  => 'This file contains exported users',
    :author   => 'Open Data Quality'
    #,
    #:hyperlink_base => url_for @users
    )

    # write description sheet
    cover = workbook.add_worksheet('Users list')
    cover.write(0, 0, "Users lists for: #{$Organisation}", title)
    cover.write(1, 0, 'All visible users', header)

    cover.write(3, 0, 'Sample user:', header)
    index = 4
    @users.first.attributes.except('calculated_status', 'organisation_id', 'is_active').map do |name, value|
      cover.write(index, 0, name, header)
      cover.write(index, 1, value, data)
      index += 1
    end

    # write data sheet
    data_sheet = workbook.add_worksheet('Users')
    index = 0
    @users.first.attributes.except('calculated_status', 'organisation_id', 'is_active').each do |attribute, value|
      data_sheet.write(0, index, attribute, header)
      index += 1
    end

    @users.each_with_index do |user, line_index|
      index = 0
      user.attributes.except('calculated_status', 'organisation_id', 'is_active').each do |attribute, value|
        data_sheet.write(line_index + 1, index, value, data)
        index += 1
      end
    end

    # close workbook
    workbook.close

    send_file "./public/users_export.xlsx", type: "application/xlsx"

  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    ### Retrieved by Callback function
    check_translations(@user)
  end

  def pass
    @user.updated_by = current_login
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    metadata_setup(@user)
    @user.current_playground_id = current_playground
    @user.active_from = Time.now
    @user.active_to = Time.now + 1.year
    @user.provider = user_params[:provider] || 'Devise'

    respond_to do |format|
      if @user.save
        @user.groups_users.create(group_id: 0, is_principal: true, active_from: @user.active_from, active_to: @user.active_to)
        format.html { redirect_to [self.class.parent.name.downcase, @user], notice: t('UserCreated') } #'User was successfully created.'
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    ### Retrieved by Callback function
    @user.updated_by = current_login
    #@user.preferred_activities = user_params[:preferred_activities].gsub(' ', '').split(',')

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to [self.class.parent.name.downcase, @user], notice: t('UserUpdated') } #'User was successfully updated.'
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    ### Retrieved by Callback function
    @user.set_as_inactive(current_login)
    respond_to do |format|
      format.html { redirect_to administration_users_path, notice: t('UserDeleted') } #'User was successfully deleted.'
      format.json { head :no_content }
    end
  end

  # Reactivate deleted user
  def activate
    ### Retrieved by Callback function
    @user.set_as_active(current_login)
    respond_to do |format|
      format.html { redirect_to [self.class.parent.name.downcase, @user], notice: t('UserRecalled')  }
      format.json { head :no_content }
    end
  end

  def set_playground
    @user.updated_by = current_login

    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to root_path, notice: t('PgSwitched') } #'User switched playground.'
       else
        format.html { redirect_to root_path, alert: 'Unable to switch playground.' }
      end
    end
  end

  # User update API to invoke with cURL:
  # curl --noproxy localhost -d @new_external_ids.json -H "Content-type: application/json" http://localhost/API/user_directory
  def set_external_reference
    puts "Loaded parameters:"
    puts params
    counter = 0
    external_users = params[:directory_entries]
    external_users.each do |user|
      if target_user = User.find_by_email(user[:identifier].downcase)
        target_user.update_attributes(external_directory_id: user[:name])
        counter += 1
      end
    end
    render json: {"Response": "OK", "Message": "Updated #{counter} users"}, status: 200
  end

### private functions
  private

  ### Use callbacks to share common setup or constraints between actions.
    # Retrieve current user
    def set_user
      @user = User.find(params[:id])
    end

    # breadcrumbs calculation from controllers helpers
    def set_breadcrumbs
      @breadcrumbs = breadcrumbs(@user)
    end

  ### before filters
    # Check for active session
    def signed_in_user
      redirect_to signin_url, notice: t('Mustlogin') unless signed_in? #"You must log in to access this page."
    end

    # Check for admin access
    def signed_as_admin
      redirect_to root_url, notice: t('MustbeAdm')  unless user_is_admin? #"You must be administrator to access this page."
    end

    ### queries tayloring
    def owners
      User.arel_table.alias('owners')
    end

    def users
      User.arel_table
    end

    def groups_users
      GroupsUser.arel_table
    end

    def groups
      Group.arel_table
    end

    def organisations
      Organisation.arel_table
    end

    def organisations_name
      Translation.arel_table.alias('tr_organisations')
    end

    def translated_users
      users.
      join(owners).on(users[:owner_id].eq(owners[:id])).
      join(groups_users).on(users[:id].eq(groups_users[:user_id]).and(groups_users[:is_principal].eq(true))).
      join(groups).on(groups_users[:group_id].eq(groups[:id])).
      join(organisations).on(users[:organisation_id].eq(organisations[:id])).
      join(organisations_name, Arel::Nodes::OuterJoin).on(organisations[:id].eq(organisations_name[:document_id]).and(organisations_name[:document_type].eq("Organisation")).and(organisations_name[:language].eq(current_language).and(organisations_name[:field_name].eq('name')))).
      join_sources
    end

    def index_fields
      [users[:id], users[:user_name], users[:first_name], users[:last_name], users[:name], users[:email],
      users[:organisation_id], users[:updated_by], users[:updated_at], users[:is_active], users[:active_from], users[:active_to],
      users[:is_admin], users[:locked_at], users[:confirmed_at], users[:sign_in_count],
      users[:language], users[:external_directory_uri],
        groups[:code].as("main_group"),
        owners[:name].as("owner_name"),
        organisations[:code].as("organisation_code"),
        organisations_name[:translation].as("organisation_name"),
        Arel::Nodes::SqlLiteral.new("case
          when not users.is_active then '0'
          else '1'
          end").as("calculated_status"),
        Arel::Nodes::SqlLiteral.new("case
        when users.locked_at is not null then 'Locked'
          when users.confirmed_at is null then 'Unconfirmed'
          when users.sign_in_count = 0 then 'Confirmed'
          when users.sign_in_count > 0 then 'Active'
          else 'Inactive'
          end").as("activity_status")]
    end

    def order_by
      [users[:user_name].asc]
    end

  ### strong parameters
  def user_params
    params.require(:user).permit(:user_name,
                                :first_name,
                                :last_name,
                                :external_directory_id,
                                :provider,
                                :uuid,
                                :organisation_id,
                                #:preferred_activities,
                                :active_from,
                                :active_to,
                                :is_admin,
                                :email,
                                :owner_id,
                                :language,
                                :password,
                                :password_confirmation,
                                :current_playground_id,
                                :remember_created_at,
                                description_translations_attributes:[:id,
                                                                    :field_name,
                                                                    :language,
                                                                    :translation],
                                :group_ids => [])
  end

  def external_params
    params.permit(:id, :external_id, :name)
  end

end
