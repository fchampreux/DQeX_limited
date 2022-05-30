# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create(id: 1, [{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(id: 1, name: 'Emanuel', city: cities.first)

### Initialise business hierarchy tables
# Process classification framework: business_areas, business_flows, business_process, activities, tasks
# Organisation of business: organisations, territories
# Import temporary table: business_hierarchies
puts "Seeding organisation"
if Organisation.count == 0
  puts "Creating hierarchy for Organisations"
  this_organisation = Organisation.create(id: 0, parent_id: 0, hierarchy: '0', name: 'Undefined organisation', description: 'This organisation is assigned an undefined value', code: 'UNDEFINED', organisation_level: 1, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1, organisation_id: 0 )
  ### create first translations for desired languages
      this_organisation.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined organisation')
      this_organisation.description_translations.create(field_name: 'description', language: 'en', translation: 'This organisation is assigned an undefined value')
  ###
end

puts "Seeding territory"
if Territory.count == 0
  puts "Creating hierarchy for Territories"
  this_territory = Territory.create(id: 0, parent_id: 0, hierarchy: '0', name: 'Undefined territory', description: 'This territory is assigned an undefined value', code: 'UNDEFINED', territory_level: 0, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1, territory_id: 0 )
  ### create first translations for desired languages
      this_territory.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined territory')
      this_territory.description_translations.create(field_name: 'description', language: 'en', translation: 'This territory is assigned an undefined value')
  ###
end

puts "Seeding business areas"
if BusinessArea.count==0
  puts "Initialising business areas"
  this_business_area = BusinessArea.create(id: 0, playground_id: 0, code: 'UNDEFINED', name: 'Undefined Business Area',  description: 'This business area is assigned an undefined value', hierarchy: '0', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1  )
  ### create first translations for desired languages
      this_business_area.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined Business Area')
      this_business_area.description_translations.create(field_name: 'description', language: 'en', translation: 'This Business Area is assigned an undefined value')
  ###
end

puts "Seeding business flows"
if BusinessFlow.count==0
  puts "Initialising business flows"
  this_business_flow = BusinessFlow.create(id: 0, playground_id: 0, business_area_id: 0, code: 'UNDEFINED', name: 'Undefined business flow', description: 'This business flow is assigned an undefined value', hierarchy: '0', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1 )
  ### create first translations for desired languages
      this_business_flow.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined Business Flow')
      this_business_flow.description_translations.create(field_name: 'description', language: 'en', translation: 'This Business Flow is assigned an undefined value')
  ###
end

puts "Seeding business processes"
if BusinessProcess.count==0
  puts "Initialising business processes"
  this_business_process = BusinessProcess.create(id: 0, playground_id: 0, business_flow_id: 0, code: 'UNDEFINED', name: 'Undefined business process', description: 'This business process is assigned an undefined value', hierarchy: '0', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1 )
  ### create first translations for desired languages
      this_business_process.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined Business Process')
      this_business_process.description_translations.create(field_name: 'description', language: 'en', translation: 'This Business Process is assigned an undefined value')
  ###
end

puts "Seeding activity"
if Activity.count == 0
  puts "Creating Activity"
  this_activity = Activity.create(id: 0, playground_id: 0, business_process_id: 0, code: 'UNDEFINED', name: 'Undefined activity', description: 'This activity is assigned an undefined value', hierarchy: '0', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1)
  puts this_activity.errors.full_messages
  ### create first translations for desired languages
      this_activity.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined Activity')
      this_activity.description_translations.create(field_name: 'description', language: 'en', translation: 'This Activity is assigned an undefined value')
  ###
end

puts "Seeding task"
if Task.count == 0
  puts "Creating Task"
  this_task = Task.create(id: 0, playground_id: 0, parent_id: 0, parent_type: 'Activity', code: 'UNDEFINED', name: 'Undefined task', description: 'This task is assigned an undefined value', status_id: 1, owner_id: 0)
  ### create first translations for desired languages
      this_task.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined Task')
      this_task.description_translations.create(field_name: 'description', language: 'en', translation: 'This Task is assigned an undefined value')
  ###
end
