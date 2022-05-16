### Redis connections for Sidekiq
Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.credentials.sidekiq[:redis_url] }
  config.on(:startup) do
    schedule_file = "config/sidekiq-cron.yml"
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.credentials.sidekiq[:redis_url] }
end

### Application configuration
DataQualityManager::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies. Requires a certificate !
  # config.force_ssl = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Store uploaded files locally.
  config.active_storage.service = :local

  # Configure authorisation list for rendering error management web console
  #config.web_console.permissions = '0.0.0.0'

  # Define connection to email services
  config.action_mailer.default_url_options = { host: Rails.application.credentials.integration[:web_server] }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
end

# Migration connections to web services
  $MigrationAuthenticator = Rails.application.credentials.integration[:authentication_url]
  $TokenURL = "/realms/bfs-sis-t/protocol/openid-connect/token"
  $MigrationTarget = Rails.application.credentials.integration[:integration_target]
  $MigrationClient = Rails.application.credentials.integration[:integration_client]
  $MigrationUser = Rails.application.credentials.integration[:integration_user]
  $MigrationPass = Rails.application.credentials.integration[:integration_pass]
