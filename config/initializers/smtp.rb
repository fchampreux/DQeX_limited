ActionMailer::Base.smtp_settings = {
    address: Rails.application.credentials.smtp[:address],
    port: 587,
    domain: "opendataquality.com",
    authentication: "plain",
    enable_starttls_auto: true,
    user_name: Rails.application.credentials.smtp[:user_name],
    password: Rails.application.credentials.smtp[:password]
    }
