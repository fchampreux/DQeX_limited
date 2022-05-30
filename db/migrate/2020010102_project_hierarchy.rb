class ProjectHierarchy < ActiveRecord::Migration[5.1]

  def change

### Create project hierarchy tables
# Subproject definitions: landscapes
# Dataset definitions: scopes
# Environments definitions: services, contexts, contexts_services

# Subproject definitions: landscapes
    create_table "landscapes", id: :serial,                        comment: "Describes a subproject within the whole playground, allows the grouping of scopes to implement data plausibilisation for a consistent part of the project" do |t|
      t.references :playground,          index: true,              comment: "Parent playground is the highest level of project's hierarchy"
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.boolean "is_finalised",                    default: true,  comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.timestamps

      #t.index ["id"], name: "index_landscapes_on_id", unique: true
      t.index ["playground_id","code"], name: "index_landscapes_on_code", unique: true
      t.index ["hierarchy"], name: "index_landscapes_on_hierarchy", unique: true
      #t.index ["playground_id"], name: "index_landscapes_on_playground_id"
      t.index ["sort_code"], name: "index_landscapes_on_sort_code"
    end

# Dataset definitions: scopes
    create_table "scopes", id: :serial,                            comment: "Describes the technical methodology to build the dataset related to the business process and requiring plausibilisation" do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :business_object,   index: true
      t.references :landscape,         index: true
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.integer "major_version",                      null: false
      t.integer "minor_version",                      null: false
      t.text "new_version_remark",       limit: 4000,              comment: "When creating a new version, the user is prompted for the reason"
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.string "load_interface",         limit: 255
      t.string "connection_string",      limit: 255
      t.string "structure_name",         limit: 255
      t.text "query",                    limit: 4000
      t.string "resource_file",          limit: 255,               comment: "Path to source file name"
      t.boolean "is_validated",                    default: false, comment: "Marks a scope with successfull data validation"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.timestamps

      #t.index ["business_object_id"], name: "index_scopes_on_business_object_id"
      t.index ["code", "major_version", "minor_version"], name: "index_scope_on_code"
      t.index ["hierarchy", "major_version", "minor_version"], name: "index_scope_on_hierarchy", unique: true
      #t.index ["id"], name: "index_scope_on_id", unique: true
      #t.index ["landscape_id"], name: "index_scopes_on_landscape_id"
      #t.index ["playground_id"], name: "index_scopes_on_playground_id"
      t.index ["sort_code"], name: "index_scopes_on_sort_code"
    end

# Environments definitions: services, contexts, contexts_services

  end
end
