class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception unless -> { request.format.json? }
  include SessionsHelper, ParametersHelper, UsersHelper, ViewsHelper, ControllersHelper,
          TranslationsHelper, MonitoringHelper, ValuesListsHelper, SkillsHelper, SchedulerExecutionHelper
  # ScopesHelper, PlaygroundsHelper, OrganisationsHelper, TerritoriesHelper,
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  #check_authorization :unless => :devise_controller?

# Unauthorised access alert
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

# Where to route user after deconnection
  def after_sign_out_path_for(current_user)
    puts "called from AFTER SIGN OUT PATH"
    new_user_session_path
  end

# Devise permitted parameters
  protected
  def configure_permitted_parameters
    added_attrs = [:email, :first_name, :last_name, :language, :language_id, :description, :playground_id, :user_name, :remember_me, :password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

end
