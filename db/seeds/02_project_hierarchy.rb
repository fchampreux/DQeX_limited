# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create(id: 1, [{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(id: 1, name: 'Emanuel', city: cities.first)

### Initialise project hierarchy tables
# Subproject definitions: landscapes
# Dataset definitions: scopes
# Environments definitions: services, contexts, contexts_services

puts "Seeding landscape"
if Landscape.count == 0
  puts "Creating Landscapes"
  this_landscape = Landscape.create(id: 0, playground_id: 0, hierarchy: '0', name: 'Undefined landscape', description: 'This landscape is assigned an undefined value', code: 'UNDEFINED', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1 )
  ### create first translations for desired languages
      this_landscape.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined landscape')
      this_landscape.description_translations.create(field_name: 'description', language: 'en', translation: 'This landscape is assigned an undefined value')
  ###
end

puts "Seeding scope"
if Scope.count == 0
  puts "Creating technical Scopes"
  this_scope = Scope.create(id: 0, playground_id: 0, landscape_id: 0, hierarchy: '0', major_version: 0, minor_version: 0, name: 'Undefined scope', description: 'This scope is assigned an undefined value', code: 'UNDEFINED', created_by: 'Rake', updated_by: 'Rake', owner_id: 1, status_id: 1 )
  ### create first translations for desired languages
      this_scope.name_translations.create(field_name: 'name', language: 'en', translation: 'Undefined scope')
      this_scope.description_translations.create(field_name: 'description', language: 'en', translation: 'This scope is assigned an undefined value')
  ###
end
