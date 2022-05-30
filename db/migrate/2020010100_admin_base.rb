class AdminBase < ActiveRecord::Migration[5.1]

  def change

### Create global sequence for application-wide identifier unicity
    execute "CREATE SEQUENCE global_seq INCREMENT BY 1 START WITH 1"

### Create application administration tables
# Multi-tenancy: playgrounds
# Application configuration: parameters_lists, parameters
# User management: users, groups, groups_users
# Authorisations: groups_roles, groups_features
# Information management: translations

# Multi-tenancy: playgrounds
    create_table "playgrounds", id: :serial,                       comment: "The playground isolates tenants in a multi-tenancy configuration. It can provide an additional level to the business hierarchy." do |t|
      t.belongs_to :playground,          index: false, default: 0, comment: "Self reference for convinience"
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

      t.index ["id"], name: "index_pg_on_id", unique: true
      t.index ["code"], name: "index_pg_on_code", unique: true
      t.index ["hierarchy"], name: "index_pg_on_hierarchy", unique: true
      t.index ["sort_code"], name: "index_playgrounds_on_sort_code"
    end

    # Application configuration: parameters_lists, parameters
    create_table "parameters_lists", id: :serial do |t|
      #t.belongs_to :playground,          index: true,              comment: "Isolates tenants in a multi-tenancy configuration"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.timestamps

      t.index ["code"], name: "index_parameters_lists_on_code", unique: true
      #t.index ["playground_id", "code"], name: "index_parameters_lists_on_code", unique: true
      #t.index ["playground_id"], name: "index_parameters_lists_on_playground_id"
      t.index ["sort_code"], name: "index_parameters_lists_on_sort_code"
    end

    create_table "parameters", id: :serial do |t|
      t.references :parameters_list,    index: true
      #t.belongs_to :playground,         index: true
      t.string "scope",                  limit: 255
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "property",               limit: 255,               comment: "Provide a readable code mapping"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.datetime "active_from",          default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.string "icon",                   limit: 255,               comment: "Icon representing the option associated to the parameter"
      t.string "style",                  limit: 255,               comment: "CSS style associated to the parameter"
      t.integer "value",                                           comment: "Value associated to the parameter"      
      t.timestamps

      t.index ["parameters_list_id", "code"], name: "index_parameters_on_code", unique: true
      #t.index ["parameters_list_id"], name: "index_parameters_on_parameters_list_id"
      #t.index ["playground_id"], name: "index_parameters_on_playground_id"
      t.index ["sort_code"], name: "index_parameters_on_sort_code"
    end

# User management: users, groups, groups_users
    create_table "users", id: :serial do |t|
      #t.belongs_to :playground,          index: true,              comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :organisation,        index: true,              comment: "The organisation the user belongs to."
      t.references :current_playground,               default: 0,  comment: "The playground actually viewed in multi-tenant configuration"
      t.string "external_directory_uri", limit: 255
      t.string "first_name",             limit: 255
      t.string "last_name",              limit: 255
      t.string "name",                   limit: 255,               comment: "Name is provided by first-name + last-name"
      t.string "user_name",              limit: 255,  null: false, comment: "User name is used for loging in"
      t.string "language" ,              limit: 255,  default: "en", comment: "User language used to diaply translated content"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.boolean "is_admin",                        default: false
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps
      t.string "email",                  limit: 255, default: "",  null: false
      t.string "encrypted_password",     limit: 255, default: "",  null: false
      t.string "reset_password_token",   limit: 255
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count",                     default: 0,  null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.string "confirmation_token",     limit: 255
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string "unconfirmed_email"
      t.integer "failed_attempts",                   default: 0,  null: false
      t.string "unlock_token",           limit: 255
      t.datetime "locked_at"
      t.uuid "uuid",                     index: true,             comment: "Uid from OmniAuth authentication service"
      t.string "provider",                                        comment: "OmniAuth provider"
      t.string :external_roles,       array: true,   default: [], comment: "List of role provided through OmniAuth"
      t.string :preferred_activities, array: true,   default: [], comment: "List of options provided through OmniAuth"
      t.string :favourite_url,           limit: 100,              comment: "Resource to display at user login"

      t.index ["email", "provider"], name: "index_users_on_email_provider", unique: true
      #t.index ["organisation_id"], name: "index_users_on_organisation_id"
      #t.index ["playground_id"], name: "index_users_on_playground_id"
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["user_name"], name: "index_users_on_user_name", unique: true
    end

    create_table "authorisations", id: :serial,                    comment: "Lists users tokens for several omniauth providers"  do |t|
      t.references :user,                index: true,              comment: "User identified by the token"
      t.uuid "uid",                      index: true, null: false, comment: "User's uid in authetication system"
      t.string "provider",               limit: 255,  null: false, comment: "Authentication provider"
      t.string "token",                  limit: 255,  null: false, comment: "Authentication token"
      t.string "secret",                 limit: 255,  null: false, comment: "Authentication secret"
      t.string "profile_page",           limit: 255,  null: false, comment: "Landing page URL"
      t.string "profile_url",            limit: 255,  null: false, comment: "User profile URL"
      t.string "image_url",              limit: 255,  null: false, comment: "User picture URL"
      t.timestamps
    end

    create_table "groups", id: :serial do |t|
      #t.belongs_to :playground,          index: true,              comment: "Isolates tenants in a multi-tenancy configuration"
      t.string "code",                   limit: 255,  null: false, comment: "Code has to be unique in a hierarchical level"
      t.string "name",                   limit: 255,               comment: "Name is translated, this field is only for fall-back"
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.references :territory,                        null: false
      t.references :organisation,                     null: false
      t.string "hierarchy_entry",        limit: 255,               comment: "Business hierarchy level to use as filter for group's scope"
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.references :status,                        default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.belongs_to :owner,                            null: false, comment: "All managed objects have a owner"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.string "sort_code",              limit: 255,               comment: "Code used for sorting displayed indexes"
      t.timestamps

      #t.index ["playground_id", "code"], name: "index_group_on_code", unique: true
      t.index ["code"], name: "index_group_on_code", unique: true
      #t.index ["playground_id"], name: "index_groups_on_playground_id"
      t.index ["sort_code"], name: "index_groups_on_sort_code"
    end

    create_table "groups_users", id: :serial do |t|
      t.references :group,               index: true
      t.references :user,                index: true
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.boolean "is_principal",                    default: false, comment: "User's main group allows notificaions routing."
      t.timestamps

      #t.index ["group_id"], name: "index_groups_users_on_group_id"
      #t.index ["user_id"], name: "index_groups_users_on_user_id"
    end

# Authorisations: groups_roles, groups_features
    create_table "groups_roles", id: :serial do |t|
      t.references :parameter,           index: true
      t.references :group,               index: true
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.timestamps

      #t.index ["group_id"], name: "index_groups_roles_on_group_id"
      #t.index ["parameter_id"], name: "index_groups_roles_on_parameter_id"
    end

# Information management: translations
    create_table "translations", id: :serial do |t|
      t.references :document,      polymorphic: true, null: false, index: true
      t.string "field_name",             limit: 255,  null: false
      t.string "language",               limit: 255,  null: false
      t.text "translation",              limit: 4000
      t.tsvector "searchable"
      t.timestamps

      t.index ["document_type", "document_id", "field_name", "language"], name: "index_translation_on_field", unique: true
      #t.index ["document_type", "document_id"], name: "index_translations_on_document_type_and_document_id"
    end

  end
end
