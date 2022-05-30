source 'https://rubygems.org'

gem 'rails', '5.2.4'
gem 'bootstrap-sass'
gem 'sassc-rails'
gem 'coffee-rails', '~> 5.0'
gem 'uglifier', '~> 4.0'
gem 'bcrypt', '~> 3.1'
gem 'jquery-rails'
gem 'turbolinks', '~> 5.2'
gem 'jquery-turbolinks'
gem 'jquery-datatables'
gem 'jbuilder', '~> 2.6'
gem 'will_paginate', '~> 3.1'
gem 'd3-rails', '~> 5.9.2'
gem 'js_cookie_rails'
gem 'faraday'
gem 'nested_form_fields'
gem 'pg'
gem 'deep_cloneable', '~> 3.0'
#gem 'acts-as-taggable-on', '~> 6.0'
gem 'tzinfo-data'
gem 'audited', '~> 4.9'
gem 'awesome_print' # Layout enhancement for Audited
gem 'open-uri' # Nokogiri partner
gem 'ruby-graphviz'
gem 'multi_logger'

# SSH tools
gem 'net-ssh'
gem 'net-scp'
# Job scheduling based on Redis / Sidekiq
gem 'sidekiq', ">= 6.4.0"
gem 'sidekiq-cron'
gem "bunny", ">= 2.9.2"

# API publication
gem 'rswag'

# Generate SQL scripts via renderer
gem 'sql_query'

# Workflow support
gem 'workflow-activerecord', '>= 4.1', '< 6.0'

# Full-text search with Postgres
gem 'pg_search'

# Use Puma as the app server
gem 'puma', '~> 5.0'

# XLSX format support
gem 'write_xlsx'
gem 'write_xlsx_rails', git: 'https://github.com/fchampreux/write_xlsx_rails.git', branch: 'master'
gem 'roo'

# Authentication and Authorisations
gem 'devise'
gem 'devise-security'
gem 'omniauth-keycloak'
gem 'omniauth-rails_csrf_protection'
gem 'email_address' # for email validation
gem 'cancancan', '~> 3.0'

# MarkDown parser
gem 'redcarpet', '~> 3.5'
# eMail notification support
#gem 'mailgun-ruby', '~>1.1'

# gem for dev and test only
group :development, :test, :validation do
  gem 'annotate'
  gem 'byebug'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 4.0'
  gem 'rswag-specs'
  gem 'factory_bot_rails', '~> 6.0'
  gem 'capybara', '~> 3.15'
  gem 'database_cleaner-active_record'
  gem 'selenium-webdriver', '~>3.140'
end

group :development do
#  gem 'web-console',           '~>3.1'
  gem 'listen',                '~>3.0'
  gem 'spring',                '~>2.0'
  gem 'spring-watcher-listen', '~>2.0'
  gem 'solargraph'
  gem 'rubocop'
end

# gem for production
group :production do
  #gem 'rails_12factor'
end
