# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create(id: 1, [{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(id: 1, name: 'Emanuel', city: cities.first)

### Initialise application administration tables
# Multi-tenancy: playgrounds
# Application configuration: parameters_lists, parameters
# User management: users, groups, groups_users
# Authorisations: groups_roles, groups_features
# Information management: translations

puts "Seeding playgrounds"
if Playground.count == 0
  puts "Creating Playgrounds"
  this_playground = Playground.create( id: -1, playground_id: 0, hierarchy: '0', name: 'Sand box', description: 'This playground is used to run non-productive tests and contains rubish', code: 'SANDBOX', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1 )
  ### create first translation for default language (en)
      this_playground.name_translations.create(field_name: 'name', language: 'en', translation: 'Sand box')
      this_playground.description_translations.create(field_name: 'description', language: 'en', translation: 'This playground is used to run non-productive tests and contains rubish')
  ###
  this_playground = Playground.create( id: 0, playground_id: 0, hierarchy: '0', name: 'Metadata governance', description: 'This playground supports Metadata management conventions', code: 'GOVERNANCE', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1 )
  ### create first translation for default language (en)
      this_playground.name_translations.create(field_name: 'name', language: 'en', translation: 'Data governance project')
      this_playground.description_translations.create(field_name: 'description', language: 'en', translation: 'This playground supports data governance activities')
  ###
end

puts "Seeding users groups"
if Group.count == 0
  puts "Creating first groups"
  this_group = Group.create(id: 0, code: 'EVERYONE', name: 'Everyone', description: 'Default group for users', territory_id: 0, organisation_id: 0, status_id: 0, owner_id: 0, created_by: 'Rake', updated_by: 'Rake')
  ### create first translations for desired languages
      this_group.name_translations.create(field_name: 'name', language: 'en', translation: 'Everyone')
      this_group.description_translations.create(field_name: 'description', language: 'en', translation: 'Default group for users')
  ###
  this_group = Group.create(code: 'ADMIN', name: 'Administrators', description: 'Software administration users', territory_id: 0, organisation_id: 0, status_id: 0, owner_id: 0, created_by: 'Rake', updated_by: 'Rake')
  ### create first translations for desired languages
      this_group.name_translations.create(field_name: 'name', language: 'en', translation: 'Administrators')
      this_group.description_translations.create(field_name: 'description', language: 'en', translation: 'Software administration users')
  ###
end

puts "Seeding groups-users" # Create links to the Everyone group as it is mandatory
ActiveRecord::Base.connection.execute("INSERT INTO dqm_app.groups_users(user_id, group_id, is_principal, is_active, active_from, created_at, updated_at) values(0, 0, true, true, current_date, current_date, current_date)")
ActiveRecord::Base.connection.execute("INSERT INTO dqm_app.groups_users(user_id, group_id, is_principal, is_active, active_from, created_at, updated_at) values(1, 0, false, true, current_date, current_date, current_date)")
ActiveRecord::Base.connection.execute("INSERT INTO dqm_app.groups_users(user_id, group_id, is_principal, is_active, active_from, created_at, updated_at) values(1, 1, true, true, current_date, current_date, current_date)")

puts "Seeding users"
if User.count == 0
  puts "Creating first users" # No translation for users
  User.create( id: 0, user_name: 'Unassigned', password: ENV["admin_pass"], password_confirmation: ENV["admin_pass"], organisation_id: 0, current_playground_id: 0, is_admin: 0, last_name: 'User', first_name: 'Undefined', description: 'Undefined user', active_from: '2000-01-01', active_to: '2100-01-01', created_by: 'Rake', updated_by: 'Rake', owner_id: 0, email: 'support@opendataquality.com')
  User.create( user_name: 'Admin', password: ENV["admin_pass"], password_confirmation: ENV["admin_pass"], organisation_id: 0, current_playground_id: 0, is_admin: 1, last_name: 'Administrator', first_name: 'Open Data Quality', description: 'Admin user', active_from: '2000-01-01', active_to: '2100-01-01', created_by: 'Rake', updated_by: 'Rake', owner_id: 0, email: 'fred@opendataquality.com')
end

puts "Seeding parameters lists"
if ParametersList.count==0
  puts "Initialising parameters lists"
  ParametersList.create(id: 0, name: 'List of Undefined', description: 'This list is assigned an undefined value', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(name: 'List of display parameters', description: 'This list contains display settings for users', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(name: 'List of languages', description: 'This list contains translated localizations', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(name: 'List of statuses', description: 'This list contains statuses allowed values', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(name: 'List of object types', description: 'This list contains dqm objects types', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)

=begin # These lists should be imported and not maintained here
  ParametersList.create(playground_id: 0, name: 'List of DQM modules', description: 'This list contains the list of installed modules', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of rules types', description: 'This list contains allowed rules types', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of rules contexts', description: 'This list contains rules implementation contexts (at insert, at update, automated ...) ', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of rules complexity', description: 'This list contains allowed values for rules complexity', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of rules severity', description: 'This list contains allowed values for rules severity', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of tasks types', description: 'This list contains available tasks types', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of breach types', description: 'This list contains the types of breaches', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of breach statuses', description: 'This list contains allowed statuses for breaches', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of user roles', description: 'This list contains dqm users roles', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of skill roles', description: 'This list contains skills roles in an analysis', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of data types', description: 'This list contains business objects skills data types', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of data units', description: 'This list contains business objects mesaures units', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of sensitivity grades', description: 'This list contains data sensitivity grades', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of aggregation methods', description: 'This list contains rules aggregation methods', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of abstraction levels', description: 'This list contains available business objects types, describing how they are built', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of environments', description: 'This list contains execution environments contexts (Dev, Test, Prod ...) ', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of OGD options', description: 'This list contains options for managing Open Governmental Data', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
  ParametersList.create(playground_id: 0, name: 'List of scripting languages', description: 'This list contains options for selecting the language used for test and correction scripts', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, is_active: true, status_id: 0)
=end
  ParametersList.all.each do |list|
    ### create first translations for english
    list.name_translations.create(field_name: 'name', language: 'en', translation: list.name)
    list.description_translations.create(field_name: 'description', language: 'en', translation: list.description)
  end
end

puts "Seeding parameters"
if Parameter.count==0
  puts "Initialising parameters" # No translation for users, only available for dropdowns in localisation files
  Parameter.create(id: 0, name: 'Undefined', code: 'UNDEFINED', property: '0', description: 'Undefined parameter', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: 0)
  Parameter.create(name: 'New', code: 'NEW', property: '0', description: 'Status is New', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of statuses').id )
  #Parameter.create( playground_id: 0,  name: 'Show monitoring', code: 'MONITORING', property: 'No', description: 'Allows the display of assessment and monitoring features', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  Parameter.create(name: 'Nb of lines', code: 'LINES', property: '10', description: 'Number of lines to display in lists', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Currency', code: 'CURRENCY', property: '€', description: 'Sets the currency for financial risk calculation', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Duration unit', code: 'DURATION', property: 'minutes', description: 'Sets the duration unit for workload calculation', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Logo filename', code: 'LOGO', property: 'ODQ_Logo.png', description: 'Selects the logo image to display', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Tag 1-Green light', code: 'green.png', property: '90', description: 'Sets the threshold for displaying a green light', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Tag 2-Yellow light', code: 'yellow.png', property: '60', description: 'Sets the threshold for displaying a yellow light', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Tag 3-Red light', code: 'red.png', property: '0', description: 'Sets the threshold for displaying a red light', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Tag 4-Grey light', code: 'grey.png', property: '0', description: 'Sets the threshold for displaying a grey light', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Root organisation level', code: 'ORGANISATION_LEVEL', property: '3', description: 'Sets the lowest level of organisation to consider in the selections', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Own organisation', code: 'ORGANISATION_ID', property: '0', description: 'Sets the parent of own organisations to consider in the selections', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  #Parameter.create( playground_id: 0,  name: 'Date excursion', code: 'DATE', property: 10, description: 'Retrieve the number of days for displaying history in objects tab', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  Parameter.create(name: 'English', code: 'en', property: 'en', description: 'Translation language', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of languages').id )
  #Parameter.create( playground_id: 0,  name: 'Logo splash', code: 'LOGO144', property: 'ODQ_Logo_compact_144.png', description: 'Condensed logo', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of display parameters').id )
  Parameter.create(name: 'Parameters List',    code: 'ParametersList',    property: 'PL', scope: 'import, manage', description: 'Lists of parameters', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Business hierarchy', code: 'BusinessHierarchy', property: 'BH', scope: 'import', description: 'Business hierarchy is used to import the Process Classification Framework', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Playground',         code: 'Playground',        property: 'PG', scope: 'manage', description: 'Playground', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Business Area',      code: 'BusinessArea',      property: 'BA', scope: 'manage', description: 'Business Area', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Business Flow',      code: 'BusinessFlow',      property: 'BF', scope: 'manage', description: 'Business Flow', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Business Process',   code: 'BusinessProcess',   property: 'BP', scope: 'manage', description: 'Business Process', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Business Rule',      code: 'BusinessRule',      property: 'BR', scope: 'import, manage', description: 'Business Rule', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Activity',           code: 'Activity',          property: 'ACT', scope: 'manage', description: 'Activity', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Task',               code: 'Task',              property: 'TASK', scope: '', description: 'Task', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Landscape',          code: 'Landscape',         property: 'LS', scope: 'import, manage', description: 'Landscape', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Scope',              code: 'Scope',             property: 'SC', scope: 'import, manage', description: 'Scope', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Business Object',    code: 'BusinessObject',    property: 'BO', scope: 'import, manage', description: 'Business Object', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Skill',              code: 'Skill',             property: 'VAR', scope: 'manage', description: 'Business object attributes', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Values List',        code: 'ValuesList',        property: 'VL', scope: 'import, manage', description: 'Lists of values', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Classification',     code: 'Classification',    property: 'CLASS', scope: 'manage', description: 'Classification of values associations', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Value',              code: 'Value',             property: 'VALUE', scope: '', description: 'Value as an item of a values list', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Mapping',            code: 'Mapping',           property: 'MAPPING', scope: '', description: 'Values association as an item of a mappings list', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Parameter',          code: 'Parameter',         property: 'PARAM', scope: '', description: 'Parameter as an item of a parameters list', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'User',               code: 'User',              property: 'USER', scope: 'import, manage', description: 'Users of the application', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Group',              code: 'Group',             property: 'GROUP', scope: 'import, manage', description: 'User groups of the application', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Organisation',       code: 'Organisation',      property: 'ORG', scope: 'import, manage', description: 'Organisations of the playground', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )
  Parameter.create(name: 'Territory',          code: 'Territory',         property: 'REG', scope: 'import, manage', description: 'Territories of the playground', active_from: '2000-01-01', active_to: '2100-01-01',  parameters_list_id: ParametersList.find_by(name: 'List of object types').id )


  Parameter.all.each do |list|
    ### create first translations for english
    list.name_translations.create(field_name: 'name', language: 'en', translation: list.name)
    list.description_translations.create(field_name: 'description', language: 'en', translation: list.description)
  end
end

puts "SQL Queries"
ActiveRecord::Base.connection.execute("update users set confirmed_at = now()")
