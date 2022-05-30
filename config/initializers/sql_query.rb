# config/initializers/sql_query.rb
SqlQuery.configure do |config|
  config.path = '/app/views/sql_templates'
  config.adapter = ActiveRecord::Base
end
