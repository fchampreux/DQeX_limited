module SessionsHelper

  def current_playground
    current_user.current_playground_id
  end

  def current_login
    current_user.user_name
  end

  def user_is_admin?
    current_user.is_admin
  end

  def current_language
    I18n.locale
  end

  # Check for active session
  def signed_in_user
    redirect_to signin_url, notice: "You must log in to access this page." unless signed_in?
  end

  def set_locale
    # https://riptutorial.com/ruby-on-rails/example/9336/set-locale-through-requests
    I18n.locale =
      params[:locale] || # Request parameter
      session[:locale] || # Current session
      (current_user.language if signed_in?) ||  # Model saved configuration
      extract_locale_from_accept_language_header || # Language header - browser config
      I18n.default_locale # Set in your config files, english by super-default
    if signed_in?
      session[:locale] = I18n.locale
    end
  end

  # Extract language from request header
  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      lg = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym
      lg.in?([ I18n.available_locales ]) ? lg : nil
    end
  end

end
