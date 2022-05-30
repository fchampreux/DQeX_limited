# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
DataQualityManager::Application.initialize!

#Plurailsation exception
ActiveSupport::Inflector.inflections do |inflection| 
  inflection.irregular "time", "time"
end


