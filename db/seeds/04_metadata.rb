# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create(id: 1, [{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(id: 1, name: 'Emanuel', city: cities.first)

### Initialise metadata tables
# Business object description: business_objects, skills
# References look-up tables: values_lists, values, mappings_lists, mappings
# Business rules specifications: business_rules
# Data quality policies to deploy: data_policies

puts "Seeding values lists"
if ValuesList.count==0
  puts "Initialising values lists"
  this_values_list = ValuesList.create(id: 0, playground_id: 0, business_area_id: 0, major_version: 0, minor_version: 0, code: 'UNDEFINED', name: 'Undefined list', description: 'This list is undefined', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 0)
  ### create first translations for desired languages
      this_values_list.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined list')
      this_values_list.description_translations.create(field_name: 'description', language: 'en', translation: 'This list is assigned an undefined value')
  ###
end

puts "Seeding values"
if Value.count==0
  puts "Initialising values"
  Value.create(id: 0, values_list_id: 0, name: 'Undefined', code: '0', description: 'Undefined value')
end

puts "Seeding business object"
if BusinessObject.count == 0
  puts "Creating first Business Object"
  this_business_object = BusinessObject.create(id: 0, playground_id: 0, parent_id: 0,  parent_type: 'BusinessArea', code: 'UNDEFINED', name: 'Undefined business object', description: 'This object is assigned an undefined value', hierarchy: '0', major_version: 0, minor_version: 0, created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1)
  ### create first translations for desired languages
      this_business_object.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined Business Object')
      this_business_object.description_translations.create(field_name: 'description', language: 'en', translation: 'This Business Object is assigned an undefined value')
  ###
end

puts "Seeding business rule"
if BusinessRule.count == 0
  puts "Creating Business Rules"
  this_business_rule = BusinessRule.create(id: 0, playground_id: 0, business_object_id: 0, rule_type_id: 0, rule_class_id: 0, severity_id: 0, complexity_id: 0, code: 'UNDEFINED', major_version: 0, minor_version: 0, name: 'Undefined business rule',
  description: 'This business rule is assigned an undefined value', hierarchy: '0', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1)
  ### create first translations for desired languages
      this_business_rule.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined Business Rule')
      this_business_rule.description_translations.create(field_name: 'description', language: 'en', translation: 'This Business Rule is assigned an undefined value')
  ###
end

puts "Seeding data policy"
if DataPolicy.count == 0
  puts "Creating data policy"
  this_data_policy = DataPolicy.create(id: 0, playground_id: 0, code: 'UNDEFINED', name: 'Undefined data policy', description: 'This data policy is assigned an undefined value',  status_id: 1,
  business_area_id: 0, territory_id: 0, organisation_id: 0,  hierarchy: '0', major_version: 0, minor_version: 0, active_from:  '2000-01-01', owner_id: 1, is_active: true, is_finalised: true, created_by: 'Rake', updated_by: 'Rake' )
  ### create first translations for desired languages
      this_data_policy.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined data policy')
      this_data_policy.description_translations.create(field_name: 'description', language: 'en', translation: 'This data policy is assigned an undefined value')
  ###
  ActiveRecord::Base.connection.execute("INSERT INTO dqm_app.data_policy_links (business_rule_id, data_policy_id) values (0,0)")
end
