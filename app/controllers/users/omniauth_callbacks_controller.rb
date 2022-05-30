class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def keycloakopenid
    # Read OmniAuth token
    auth = request.env["omniauth.auth"]
    # auth.extra.raw_info.resource_access.map {|h| h[1].roles.map(&:itself).join(',')} provides the list of all roles
    # resources_accesses.first[1].roles provides an array hash

    Rails.logger.http.info("---!!!---!!!------ OmniAuth Callback --------!!!---!!!---")
    Rails.logger.http.info("--- Allowed origins")
    Rails.logger.http.info(auth.extra.raw_info)
    Rails.logger.http.info("--- Allow list")
    Rails.logger.http.info(auth.extra.raw_info.allowlists)
    Rails.logger.http.info("--- Clients")
    Rails.logger.http.info(auth.extra.raw_info.aud)
    Rails.logger.http.info("--- Server")
    Rails.logger.http.info(auth.extra.raw_info.iss)
    Rails.logger.http.info("--- User")
    Rails.logger.http.info(auth.info.name)
    Rails.logger.http.info("--- Provider")
    Rails.logger.http.info(auth.provider)
    Rails.logger.http.info("--- Ressource access")
    Rails.logger.http.info(auth.extra.raw_info.resource_access)
    #Rails.logger.http.info("---!!!---!!!------ Devise Cookie --------!!!---!!!---")
    #Rails.logger.http.info(session["devise.keycloakopenid_data"])
    Rails.logger.http.info("---!!!---!!!------ OmniAuth Callback --------!!!---!!!---")

    @user = User.from_omniauth(auth) # Finds or create the user
    if @user.persisted?
      # The user has been idetified or created: then manage groups, activities access and roles
      # 1-set roles in user's external_roles array
      # 2-set statistical activities in user's preferred_activities array
      # 3-make sure that the user is a member of the relevant groups (Everyone and External users)

      # 1-set roles in user's external_roles array
      @user.external_roles = Array.new
      resources_accesses = auth.extra.raw_info.resource_access
      resources_accesses.each do |access|
        puts access # Provides the resources_access hash
        puts access[0] # Provides the resources_access label
        puts access[1] # Provides the resources_access roles array
        # Check if label matches needed entries
        if ["BFS.SIS.SMS", "BFS.SIS", "BFS.SIS.SCHEDULER"].include? access[0].to_s
          access[1].roles.each do |role|
            # Store each role in the roles array
            @user.external_roles << role
          end
        end
      end
      
      # 2-set statistical activities in user's preferred_activities array
      @user.preferred_activities = auth.extra.raw_info.allowlists.statisticalActivities.split(',')
      @user.save

      # 3 associate user to the relevant groups
      group = Group.where(code: 'EXTERNAL').take || Group.find(0)
      @user.groups_users.create(group_id: 0,
                                is_principal: false,
                                active_from: @user.active_from
                                ) unless GroupsUser.where(group_id: 0,
                                                          user_id: @user.id).exists?
      @user.groups_users.create(group_id: group.id,
                                is_principal: true,
                                active_from: @user.active_from
                                ) unless GroupsUser.where(group_id: group.id,
                                                          user_id: @user.id).exists?

      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to new_user_session_path
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end
