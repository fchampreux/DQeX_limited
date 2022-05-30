class Metadata < ActiveRecord::Migration[5.1]

  def change

### Create metadata tables
# Business object description: business_objects, skills
# References look-up tables: values_lists, values, mappings_lists, mappings
# Business rules specifications: business_rules
# Data quality policies to deploy: data_policies

# Business object description: business_objects, skills
    create_table "business_objects", id: :serial,                  comment: "Describes an object in the scope of the business area, or elsewhere it is used" do |t|
      t.references :playground,                      index: true,  comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :parent,  polymorphic: true,      index: true,  comment: "The Objet can exist at various abstraction levels, thus belonging to various parents"
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.boolean "is_template",                     default: true,  comment: "Flags the business object as a model to build other concepts - shortcut flag for abstraction_id"
      t.references :template_object,                   default: 0, comment: "References the business object used as template"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.text "external_description",     limit: 4000,              comment: "Description used for external dissemination"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.integer "major_version",                      null: false
      t.integer "minor_version",                      null: false
      t.text "new_version_remark",       limit: 4000,              comment: "When creating a new version, the user is prompted for the reason"
      t.boolean "is_published",                    default: true,  comment: "The topic is published for external usage. Concepts used to build other objects (such as Address) are not published"
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "period",                 limit: 255,               comment: "The period these data relate to"
      t.references :ogd,                           default: 0,     comment: "Open Governmental Data management"
      t.string "resource_file",          limit: 255,               comment: "Resource filename to provide these data"
      t.references :granularity,                   default: 0,     comment: "Aggregation level covered by the dataset"
      t.string "physical_name",          limit: 255,               comment: "Physical name of the data object"
      t.references :technology,  comment: "References the connection string for this object"
      t.string "resource_name", limit: 255, comment: "Name of the external file or web service used to store the master data"
      t.string "resource_list", limit: 255, comment: "List of master data identifiers to import"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.string "type",                                             comment: "Type of business object: concept, deployed, acquired"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.string "workflow_state"
      t.timestamps

      t.index ["hierarchy", "major_version", "minor_version"], name: "index_business_objects_on_hierarchy", unique: true
      t.index ["id"], name: "index_business_objects_on_id", unique: true
      t.index ["parent_type", "parent_id", "code", "major_version", "minor_version"], name: "index_business_objects_on_code", unique: true
      #t.index ["parent_type", "parent_id"], name: "index_business_objects_on_parent_type_and_parent_id"
      #t.index ["playground_id"], name: "index_business_objects_on_playground_id"
      t.index ["sort_code"], name: "index_business_objects_on_sort_code"
    end

      create_table "business_objects_organisations", id: :serial, force: :cascade do |t|
        t.references :business_object
        t.references :organisation
        t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
        t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
        t.datetime "active_to"
        t.timestamps
      end


    create_table "skills", id: :serial, comment: "Skills are the attributes of a Business Object" do |t|
      t.references :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :business_object,   index: true
      t.string "code",                   limit: 255,  null: false, comment: "The code represents the physical column name of described dataset"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.text "external_description",     limit: 4000,              comment: "Description used for external dissemination"
      t.boolean "is_template",                     default: true,  comment: "The skill defines a concept"
      t.references :template_skill,                default: 0,     comment: "Reference to the skill from the standard object used to define this data element"
      t.references :skill_type,                    default: 0,     comment: "Datatype from available types list"
      t.references :skill_aggregation,             default: 0,     comment: "Default aggregation behaviour"
      t.integer "skill_min_size",                  default: 0,     comment: "Minimum size for content"
      t.integer "skill_size",                                      comment: "Maximum size for content"
      t.integer "skill_precision",                                 comment: "Number of digits after decimal point"
      t.references :skill_unit,                    default: 0,     comment: "Unit of measure"
      t.references :skill_role,                    default: 0,     comment: "Role assigned to the skill when it is used (key, dimension, measure, attribute)"
      t.boolean "is_mandatory",                    default: false, comment: "Flads the skill as mandatory, null or empty values will be rejected at validation"
      t.boolean "is_array",                        default: false, comment: "The skill can store several values"
      t.boolean "is_pk",                           default: false, comment: "The skill contributes to the primary key of the record"
      t.boolean "is_ak",                           default: false, comment: "The skill contributes to build an alternate key or business key for the record"
      t.boolean "is_published",                    default: true,  comment: "Lets the skill visible for external users"
      t.boolean "is_multilingual",                 default: false, comment: "The skill contains a hash of values in several languages"
      t.references :sensitivity,                   default: 0
      t.references :status,                        default: 0,     comment: "Status supports review process at skill level"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.string "regex_pattern",           limit: 255,              comment: "Valid value pattern"
      t.string "min_value",               limit: 255,              comment: "Minimum value allowed"
      t.string "max_value",               limit: 255,              comment: "Maximum value allowed"
      t.string "created_by",              limit: 255,  null: false
      t.string "updated_by",              limit: 255,  null: false
      t.boolean "is_pairing_key",                  default: false, comment: "This key can be used for record association"
      t.references :source_type,                   default: 0,     comment: "Method used for data acquisition"
      t.references :organisation,                  default: 0,     comment: "Organisation who is responsible for the data"
      t.references :responsible,                   default: 0,     comment: "User who is responsible for the data"
      t.references :deputy,                        default: 0,     comment: "Deputy who is responsible for the data"
      t.json "anything"
      t.references :values_list
      t.references :classification
      t.string "type"
      t.string "filter",                   limit: 255,             comment: "Filter expression for the allowed values list (reference)"
      t.string "sort_code",                limit: 255,             comment: "Code used for sorting displayed indexes"
      t.string "physical_name",            limit: 255,             comment: "Physical name of the variable in the database.\n                                                                      Usually, the variable's code is used, but in the case of existing tables,\n                                                                      the physical name ensures backward compatibility."
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.string "workflow_state"
      t.timestamps

      t.index ["business_object_id", "code"], name: "index_skills_on_code", unique: true
      #t.index ["business_object_id"], name: "index_skills_on_business_object_id"
      #t.index ["playground_id"], name: "index_skills_on_playground_id"
      t.index ["sort_code"], name: "index_skills_on_sort_code"
      t.index ["template_skill_id"], name: "index_skill_on_template_skill"
    end

    create_table "skills_values_lists", id: :serial, force: :cascade do |t|
      t.belongs_to :playground, default: 0, null: false, comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :skill       ,           index: true
      t.references :values_list ,           index: true
      t.references :type,      default: 0,              comment: "Type of link to the skill (masterdata, quality, methodology...)"
      t.string "filter",        limit: 255,              comment: "Filter expression for the linked values_list"
      t.text "description",                              comment: "Description of link"
    end


# References look-up tables: values_lists, values, mappings_lists, mappings
    create_table "values_lists", id: :serial, comment: "Values lists provide hierarchical lists of reference data"  do |t|
      t.references :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :business_area,     index: true
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the theme"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the theme"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the theme"
      t.boolean "is_hierarchical",        default: false
      t.integer "max_levels",             default: 1,  null: false
      t.string "code",                   limit: 255,   null: false
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "resource_name",         limit: 255,               comment: "Name of the external file or table used to store the master data"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.integer "major_version",                      null: false
      t.integer "minor_version",                      null: false
      t.text "new_version_remark",       limit: 255
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.references :list_type,  default: 0, comment: "Type of values_list (Masterdata, Quality, Infrastructure, or Methodology)"
      t.references :code_type,  default: 0, comment: "Defines the type of index that should be used and validated."
      t.integer "code_max_length", default: 32, comment: "Defines the maximum length of the index value."
      t.json "anything"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.string "workflow_state"
      t.timestamps

      t.index ["business_area_id", "code", "major_version", "minor_version"], name: "index_values_lists_on_code", unique: true
      #t.index ["business_area_id"], name: "index_values_lists_on_business_area_id"
      t.index ["hierarchy", "major_version", "minor_version"], name: "index_values_lists_on_hierarchy", unique: true
      t.index ["id"], name: "index_values_lists_on_id", unique: true
      #t.index ["playground_id"], name: "index_values_lists_on_playground_id"
      t.index ["sort_code"], name: "index_values_lists_on_sort_code"
    end

    create_table "values", id: :serial do |t|
      #t.references :playground,                                    comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :values_list,         index: true
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.integer "level",                 default: 0
      t.references :parent
      t.string "alternate_code", limit: 255
      t.string "alias", limit: 255
      t.string "abbreviation", limit: 255
      t.json "anything"
      t.datetime "active_from", default: -> { "CURRENT_DATE" },    comment: "Validity period"
      t.datetime "active_to"
      t.references :classification
      t.references :owner
      t.references :status
      t.string "uri",                                              comment: "Uniform Resource Identifier"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.timestamps

      #t.index ["parent_id"], name: "index_values_on_parent_id"
      #t.index ["playground_id"], name: "index_values_on_playground_id"
      t.index ["sort_code"], name: "index_values_on_sort_code"
      t.index ["values_list_id", "code"], name: "index_values_on_code", unique: true
      #t.index ["values_list_id"], name: "index_values_on_values_list_id"
    end

    create_table "classifications", id: :serial,                   comment: "Describes a hierarchy of values based on values-lists, such as a value set, a classification, an historised list, or a transcoding table.", force: :cascade do |t|
      t.references :playground_id,        index: true,             comment: "Isolates tenants in a multi-tenancy configuration"
      t.belongs_to :business_area,        index: true, null: false
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the classification"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the classification"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the classification"
      t.string "code",                    limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                                 limit: 255, comment: "Name is translated, this field is only for fall-back"
      t.text "description",                                        comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",               limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.references :type,                             default: 0, comment: "The type describes the usage of the hierarchy: value set, classification, historisation, mapping"
      t.references :status,                            default: 0, comment: "Status is used for validation workflow in some objects only"
      t.datetime "active_from",    default: -> { "CURRENT_DATE" }, comment: "Validity period"
      t.datetime "active_to"
      t.integer "major_version", null: false
      t.integer "minor_version", null: false
      t.text "new_version_remark",                                 comment: "When creating a new version, the user is prompted for the reason"
      t.boolean "is_published",                     default: true, comment: "The topic is published for external usage. Concepts used to build other objects (such as Address) are not published"
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                       default: true, comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                        default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",              limit: 255, null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",              limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
      t.string "workflow_state"
      t.json "anything"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.uuid "uuid",                     index: true,              comment: "Universally unique identifier through organisations"
      t.timestamps

      t.index ["business_area_id", "code", "major_version", "minor_version"], name: "index_classification_on_code", unique: true
      #t.index ["business_area_id"], name: "index_classifications_on_business_area_id"
      t.index ["hierarchy", "major_version", "minor_version"], name: "index_classification_on_hierarchy", unique: true
      t.index ["id"], name: "index_classification_on_id", unique: true
      #t.index ["playground_id"], name: "index_classifications_on_playground_id"
      t.index ["sort_code"], name: "index_classifications_on_sort_code"
    end

    create_table "values_lists_classifications", id: :serial,      comment: "Links a classification to values-lists including filter and description", force: :cascade do |t|
      t.belongs_to :playground,     index: true,                   comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :classification, index: true,    null: false
      t.references :values_list,    index: true,    null: false
      t.text "description",                         null: false,   comment: "Description of link"
      t.string "filter",            limit: 255,                    comment: "Filter expression for the linked values_list"
      t.references :type,                             default: 0, comment: "The type of link"
      t.json "anything"
      t.integer "level",         default: 0,        null: false,   comment: "Level in the classification hierarchy"
    end

    create_table "values_to_values", id: :serial,                  comment: "Links a classification to values-lists including filter and description", force: :cascade do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :classification,    index: true, null: false
      t.references :values_list,       index: true, null: false
      t.references :child_values_list, index: true, null: false
      t.references :value,             index: true, null: false
      t.references :child_value,       index: true, null: false
      t.string "code",     limit: 255,              null: false,   comment: "Code for this link"
      t.string "name",     limit: 255,                             comment: "Name of the event causing this link "
      t.text "description",                                        comment: "Details the reasons for this link"
      t.datetime "active_from", default: -> { "CURRENT_DATE" },    comment: "Validity period"
      t.datetime "active_to"
      t.references :type,                             default: 0, comment: "The type of link"
      t.integer "sort_order",                          default: 0
      t.json "anything"

      #t.index ["child_value_id"], name: "index_values_to_values_on_child_value_id"
      #t.index ["child_values_list_id"], name: "index_values_to_values_on_child_values_list_id"
      t.index ["classification_id", "sort_order"], name: "index_classification_values_on_sort_order"
      t.index ["classification_id", "values_list_id"], name: "index_classification_values_on_values_list"
      #t.index ["classification_id"], name: "index_values_to_values_on_classification_id"
      #t.index ["playground_id"], name: "index_values_to_values_on_playground_id"
      #t.index ["value_id"], name: "index_values_to_values_on_value_id"
      #t.index ["values_list_id"], name: "index_values_to_values_on_values_list_id"
    end

# Join table
    create_table "skills_values_lists", id: :serial, force: :cascade do |t|
      t.references :skill,        index: true
      t.references :values_list,  index: true
      t.references :playground,         default: 0, null: false, comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :type,                            default: 0, comment: "Type of link to the skill (masterdata, quality, methodology...)"
      t.string "filter",          limit: 255,                     comment: "Filter expression for the linked values_list"
      t.text "description",                                       comment: "Description of link"
    end


# Business rules specifications: business_rules
    create_table "business_rules", id: :serial, comment: "Describes a plausibilisation rule required to ensure the business process produces a consistent output" do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :business_object,                               comment: "The rule applies to a business object involved in the business process"
      t.references :skill,                                         comment: "The rule targets this skill, but can involve more in its description"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.integer "major_version",                      null: false
      t.integer "minor_version",                      null: false
      t.text "new_version_remark",       limit: 4000,              comment: "When creating a new version, the user is prompted for the reason"
      t.boolean "is_published",                    default: true,  comment: "The topic is published for external usage"
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.string "evaluation_contexts",    limit: 255,               comment: "The rule may be available for a specific user action: update, data import, creation..."
      t.references :default_aggregation,           default: 0,     comment: "How to aggregate the count of records rejected due to this rule "
      t.string "ordering_sequence",      limit: 255,               comment: "provides a specific sequencing for rules execution when creating a data policy"
      t.text "business_value",          limit: 4000,               comment: "Added value from the business point of view"
      t.text "check_description",       limit: 4000,               comment: "Scenario for testing the plausibility of targeted data"
      t.text "check_script",            limit: 4000,               comment: "The rule can be evaluated by a script writen in defined language hereunder"
      t.text "check_error_message",     limit: 4000,               comment: "Additonnally to linked tasks, an error message can be raised"
      t.references :check_language,                default: 0
      t.text "correction_method",       limit: 4000,               comment: "Method description for solving the issue"
      t.text "correction_script",       limit: 4000,               comment: "The rule can be corrected by a script writen in defined language hereunder"
      t.references :correction_language,           default: 0
      t.text "white_list",              limit: 4000,               comment: "List of records identifiers that should not be tested"
      t.float "added_value",                       default: 0,     comment: "Metrics for assessment"
      t.float "maintenance_cost",                  default: 0,     comment: "Metrics for assessment"
      t.float "maintenance_duration",              default: 0,     comment: "Metrics for assessment"
      t.references :duration_unit,                 default: 0,     comment: "Unit of measure"
      t.references :rule_type,                     default: 0,     comment: "Rule classification"
      t.references :severity,                      default: 0,     comment: "Metrics for assessment"
      t.references :complexity,                    default: 0,     comment: "Metrics for assessment"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.references :organisation,                      default: 0, comment: "Organisation who is responsible for the rule"
      t.references :responsible,                       default: 0, comment: "User who is responsible for the rule"
      t.references :deputy,                            default: 0, comment: "Deputy who is responsible for the rule"
      t.integer "is_template",                         default: 1, comment: "Flags the rule as a model to build other rules"
      t.references :template_object,                   default: 0, comment: "References the rule used as template"
      t.references :rule_class,                        default: 0, comment: "Rule class from business classification"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.string "workflow_state"
      t.timestamps

      t.index ["business_object_id", "code", "major_version", "minor_version"], name: "index_business_ruleson_code", unique: true
      #t.index ["business_object_id"], name: "index_business_rules_on_business_object_id"
      t.index ["hierarchy", "major_version", "minor_version"], name: "index_business_ruleson_hierarchy", unique: true
      t.index ["id"], name: "index_business_rules_on_id", unique: true
      #t.index ["playground_id"], name: "index_business_rules_on_playground_id"
      #t.index ["skill_id"], name: "index_business_rules_on_skill_id"
      t.index ["sort_code"], name: "index_business_rules_on_sort_code"
    end

    create_table "rules_for_processes", id: false, comment: "This table links business_rules to business_processes within a Data Policy" do |t|
      t.belongs_to :playground      ,        index: true
      t.references :business_rule   ,        index: true
      t.references :business_process,        index: true
      t.references :data_policy     ,        index: true

      t.index ["playground_id", "data_policy_id"], name: "index_rfp_on_policy"
    end

# Data quality policies: data_policies
    create_table "data_policies", id: false, comment: "The Data Policy is a consistent group of rules to deploy in a specific context" do |t|
      t.bigint "id",                                  null: false,  default: -> { "nextval('global_seq')" }
      t.belongs_to :playground,        index: true,               comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :business_area,     index: true
      t.references :landscape,         index: true
      t.references :territory,         index: true
      t.references :organisation,      index: true,  default: 0, comment: "Organisation who is responsible for the policy"
      t.references :responsible,       index: true,  default: 0, comment: "User who is responsible for the policy"
      t.references :deputy,            index: true,  default: 0, comment: "Deputy who is responsible for the policy"
      t.references :calendar_from,     index: true,  class: :time_scale
      t.references :calendar_to,       index: true,  class: :time_scale
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.string "hierarchy",              limit: 255,  null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.integer "major_version",                      null: false
      t.integer "minor_version",                      null: false
      t.text "new_version_remark",       limit: 4000,             comment: "When creating a new version, the user is prompted for the reason"
      t.boolean "is_published",                    default: true,  comment: "The topic is published for external usage"
      t.boolean "is_finalised",                    default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
      t.boolean "is_current",                      default: true,  comment: "Used with versionned objects, flags the current version of an object"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.references :context,                       default: 0,     comment: "Provides the context of execution of the policy (Dev, Test, Prod or other)"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.timestamps

      #t.index ["business_area_id"], name: "index_data_policies_on_business_area_id"
      #t.index ["calendar_from_id"], name: "index_data_policies_on_calendar_from_id"
      #t.index ["calendar_to_id"], name: "index_data_policies_on_calendar_to_id"
      t.index ["hierarchy", "major_version", "minor_version"], name: "index_data_policieson_hierarchy", unique: true
      #t.index ["id"], name: "index_data_policieson_id", unique: true
      #t.index ["landscape_id"], name: "index_data_policies_on_landscape_id"
      #t.index ["organisation_id"], name: "index_data_policies_on_organisation_id"
      t.index ["playground_id", "code", "major_version", "minor_version"], name: "index_data_policieson_code", unique: true
      #t.index ["playground_id"], name: "index_data_policies_on_playground_id"
      t.index ["sort_code"], name: "index_data_policies_on_sort_code"
      #t.index ["territory_id"], name: "index_data_policies_on_territory_id"
    end

    create_table :data_policy_links, id: false, comment: "Specifies which business rules to apply for which scope within a data policy" do |t|
      t.references :business_rule, index: true
      t.references :data_policy, index: true
    end

    create_table "annotations", id: :serial,                                       comment: "Additional descriptive information", force: :cascade do |t|
      t.belongs_to :playground,       null: false, index: true,                    comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :object_extra,     null: false, polymorphic: true, index: true, comment: "Object related to the annotation"
      t.references :annotation_type,  null: false, index: true,                    comment: "Allows annotations quick filtering by type"
      t.string "code",                null: false, limit: 255
      t.string "name",                             limit: 255
      t.text "description"
      t.string "uri",                              limit: 255
      t.string "sort_code",                        limit: 255
      t.timestamps

      t.index ["sort_code"], name: "index_annotations_on_sort_code"
    end

  end
end
