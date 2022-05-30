class BusinessHierarchy < ActiveRecord::Migration[5.1]

  def change

### Create business hierarchy tables
# Process classification framework: business_areas, business_flows, business_process, activities, tasks
# Organisation of business: organisations, territories
# Import temporary table: business_hierarchies

    create_table "business_areas", id: false, comment: "Provides the entry level of the business hierarchy. Describes the subject matter." do |t|
      t.bigint "id",                                  null: false, default: -> { "nextval('global_seq')" }
      t.belongs_to :playground,          index: true,              comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.string "pcf_index",              limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.string "pcf_reference",          limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.boolean "is_finalised",                    default: true,  comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.timestamps

      t.index ["hierarchy"], name: "index_ba_on_hierarchy", unique: true
      t.index ["id"], name: "index_ba_on_id", unique: true
      t.index ["playground_id", "code"], name: "index_ba_on_code", unique: true
      #t.index ["playground_id"], name: "index_business_areas_on_playground_id"
      t.index ["sort_code"], name: "index_business_areas_on_sort_code"
    end

    create_table "business_flows", id: false, comment: "Logically groups consitent processses" do |t|
      t.bigint "id",                                  null: false, default: -> { "nextval('global_seq')" }
      t.references :playground,     index: true,                   comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :business_area,  index: true
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.string "pcf_index",              limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.string "pcf_reference",          limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.boolean "is_finalised",                    default: true,  comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.datetime "active_from",    default: -> { 'current_date' }, comment: "Start date of the activity"
      t.datetime "active_to",      default: -> { 'current_date' }, comment: "End date of the activity"
      t.text "legal_basis",                                        comment: "Legal basis for the activity"
      t.references :collect_type,  default: 0,                     comment: "Main collect method of the activity"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.timestamps

      t.index ["business_area_id", "code"], name: "index_business_flows_on_code", unique: true
      #t.index ["business_area_id"], name: "index_business_flows_on_business_area_id"
      t.index ["hierarchy"], name: "index_business_flows_on_hierarchy", unique: true
      t.index ["id"], name: "index_business_flows_on_id", unique: true
      #t.index ["playground_id"], name: "index_business_flows_on_playground_id"
      t.index ["sort_code"], name: "index_business_flows_on_sort_code"
    end

    create_table "business_flows_organisations", id: :serial, force: :cascade, comment: "Lists the organisations involved in the Business Flow" do |t|
      t.references :business_flow,        index: true
      t.references :organisation,         index: true
      t.boolean "is_active",    default: true,                                 comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.datetime "active_from", default: -> { "CURRENT_DATE" },                comment: "Validity period"
      t.datetime "active_to",                                                  comment: "Universally unique identifier through organisations"
      t.timestamps

      #t.index ["business_flow_id"], name: "index_business_flows_organisations_on_business_flow_id"
      #t.index ["organisation_id"], name: "index_business_flows_organisations_on_organisation_id"
    end

    create_table "business_processes", id: false, comment: "Describes a process involving business objects and requiring business rules" do |t|
      t.bigint "id",                                  null: false, default: -> { "nextval('global_seq')" }
      t.references :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :business_flow,     index: true
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.string "pcf_index",              limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.string "pcf_reference",          limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.boolean "is_finalised",                    default: true,  comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.json "parameters",                                         comment: "Specify parameters for process"
      t.references :gsbpm,                                         comment: "Associate GSBPM process"
      t.string "version",                limit: 255,               comment: "Version of the deployed production job"
      t.timestamps

      t.index ["business_flow_id", "code"], name: "index_business_processes_on_code", unique: true
      #t.index ["business_flow_id"], name: "index_business_processes_on_business_flow_id"
      t.index ["hierarchy"], name: "index_business_processes_on_hierarchy", unique: true
      t.index ["id"], name: "index_business_processes_on_id", unique: true
      #t.index ["playground_id"], name: "index_business_processes_on_playground_id"
      t.index ["sort_code"], name: "index_business_processes_on_sort_code"
    end

    create_table "business_processes_organisations", id: :serial, force: :cascade, comment: "Lists the organisations involved in the Business Process" do |t|
      t.references :business_process,        index: true
      t.references :organisation,            index: true
      t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
      t.datetime "active_to"
      t.timestamps

      #t.index ["business_process_id"], name: "index_business_processes_organisations_on_business_process_id"
      #t.index ["organisation_id"], name: "index_business_processes_organisations_on_organisation_id"
    end

    create_table "activities", id: false, comment: "Describes a milestone of the business process" do |t|
      t.bigint "id",                                  null: false, default: -> { "nextval('global_seq')" }
      t.references :playground,       index: true,                 comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :business_process, index: true
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.string "pcf_index",              limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.string "pcf_reference",          limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.references :success_next,                                  comment: "Links to the next activity in case of success"
      t.references :failure_next,                                  comment: "Links to the next activity in case of failure"
      t.boolean "is_synchro",                                      comment: "Waits for all preceeding activities to complete before starting"
      t.boolean "is_template",                     default: false, comment: "Flags the activity as template"
      t.references :template,                                      comment: "Id of the activity used as template"
      t.references :technology,                                    comment: "References a specific connection string for this activity"
      t.references :target_object,                                 comment: "Target business object to apply the template"
      t.json "parameters",                                         comment: "Specify parameters for activity"
      t.references :node_type,                     default: 0,     comment: "Drives the node's behaviour"
      t.references :gsbpm,                                         comment: "Associate GSBPM sub-process"
      t.json :parameters,                                          comment: "Specify parameters for the activity"
      t.timestamps

      t.index ["business_process_id", "code"], name: "index_activities_on_code", unique: true
      #t.index ["business_process_id"], name: "index_activities_on_business_process_id"
      t.index ["hierarchy"], name: "index_activities_on_hierarchy", unique: true
      t.index ["id"], name: "index_activities_on_id", unique: true
      #t.index ["playground_id"], name: "index_activities_on_playground_id"
      t.index ["sort_code"], name: "index_activities_on_sort_code"
    end

    create_table "tasks", id: false, comment: "Describes the smallest item to realise within a activity" do |t|
      t.bigint "id",                                  null: false,  default: -> { "nextval('global_seq')" }
      t.references :playground,                       index: true,  comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :parent,        polymorphic: true, index: true, comment: "The task can exist in an activity, or describe measures related to a business rule or an incident"
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.string "pcf_index",              limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.string "pcf_reference",          limit: 255,               comment: "Reference to an external Process Classification Framework, such as APQC's"
      t.references :task_type,                     default: 0
      t.text "script",                                             comment: "The task can be executed by a script writen in defined language hereunder"
      t.references :script_language,               default: 0,     comment: "Programming language used for sepcifying the task."
      t.string "external_reference",     limit: 255,               comment: "Reference to an external process"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.boolean "is_finalised",                    default: true,  comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.references :success_next,                                  comment: "Links to the next activity in case of success"
      t.references :failure_next,                                  comment: "Links to the next activity in case of failure"
      t.boolean "is_synchro",                                      comment: "Waits for all preceeding tasks to complete before starting"
      t.boolean "is_template",                     default: false, comment: "Flags the task as template"
      t.references :template,                                      comment: "Id of the task used as template"
      t.references :technology,                                    comment: "References a specific connection string for this task"
      t.references :target_object,                                 comment: "Target business object to apply the template"
      t.string "script_path",            limit: 255,               comment: "Path to the script location"
      t.string "git_hash",               limit: 255,               comment: "Version management reference"
      t.json "parameters",                                         comment: "Specify parameters for task"
      t.references :node_type,                     default: 0,     comment: "Drives the node's behaviour"
      t.string "script_name",            limit: 255,               comment: "Name of the script to execute"
      t.string "return_value_pattern",   limit: 255,               comment: "Format to expect for the statement's return value"
      t.text "statement",                                          comment: "Statement to execute (to run a script)"
      t.references :statement_language,                            comment: "Statement language (OS specific )"
      t.references :gsbpm,                                         comment: "Associate GSBPM sub-process"
      t.timestamps

      t.index ["id"], name: "index_tasks_on_id", unique: true
      t.index ["parent_type", "parent_id", "code"], name: "index_task_on_code", unique: true
      #t.index ["parent_type", "parent_id"], name: "index_tasks_on_parent_type_and_parent_id"
      #t.index ["playground_id"], name: "index_tasks_on_playground_id"
      t.index ["sort_code"], name: "index_tasks_on_sort_code"    end

# Organisation of business: organisations, territories
    create_table "organisations", id: :serial do |t|
      #t.references :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :organisation,      index: true
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.integer "organisation_level",              default: 0
      t.string "hierarchy",              limit: 255
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.references :parent
      t.string "external_reference",     limit: 255
      t.boolean "is_finalised",                    default: false,  comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.timestamps

      t.index ["external_reference"], name: "index_organisationson_ext_ref", unique: true
      t.index ["hierarchy"], name: "index_organisationson_hierarchy", unique: true
      t.index ["code"], name: "index_organisationson_code", unique: true
      #t.index ["playground_id", "code"], name: "index_organisationson_code", unique: true
      #t.index ["playground_id"], name: "index_organisations_on_playground_id"
      t.index ["sort_code"], name: "index_organisations_on_sort_code"
    end

    create_table "territories", id: :serial do |t|
      t.references :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :territory,         index: true
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.integer "territory_level",              default: 0
      t.string "hierarchy",              limit: 255
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.references :parent
      t.string "external_reference",     limit: 255
      t.boolean "is_finalised",                    default: false,  comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.timestamps

      t.index ["external_reference"], name: "index_territorieson_ext_ref", unique: true
      t.index ["hierarchy"], name: "index_territorieson_hierarchy", unique: true
      t.index ["code"], name: "index_territorieson_code", unique: true
      #t.index ["playground_id", "code"], name: "index_territorieson_code", unique: true
      #t.index ["playground_id"], name: "index_territories_on_playground_id"
      t.index ["sort_code"], name: "index_territories_on_sort_code"
    end

# Import temporary table: business_hierarchies
    create_table "business_hierarchies", id: :serial, force: :cascade do |t|
      t.references :playground
      t.string "pcf_index"
      t.string "pcf_reference"
      t.integer "hierarchical_level"
      t.string "hierarchy"
      t.string "name"
      t.string "name_en"
      t.string "name_fr"
      t.string "name_de"
      t.string "name_it"
      t.text "description"
      t.text "description_en"
      t.text "description_fr"
      t.text "description_de"
      t.text "description_it"
      t.string "responsible", limit: 255, comment: "Organisations who are responsibles for the Business Flow"
      t.string "field", limit: 255, comment: "Landscape covered by the Business Flow"
      t.string "funding", limit: 255, comment: "Organisations who finance the Business Flow"
      t.timestamps

      t.index ["hierarchical_level"], name: "index_BH_on_level"
      t.index ["hierarchy"], name: "index_BH_on_hierarchy", unique: true
    end

  end
end
