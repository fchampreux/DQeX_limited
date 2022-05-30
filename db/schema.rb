# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_05_12_122000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", id: false, comment: "Describes a milestone of the business process", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('global_seq'::regclass)" }, null: false
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_process_id"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.string "pcf_index", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.string "pcf_reference", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.bigint "success_next_id", comment: "Links to the next activity in case of success"
    t.bigint "failure_next_id", comment: "Links to the next activity in case of failure"
    t.boolean "is_synchro", comment: "Waits for all preceeding activities to complete before starting"
    t.boolean "is_template", default: false, comment: "Flags the activity as template"
    t.bigint "template_id", comment: "Id of the activity used as template"
    t.bigint "technology_id", comment: "References a specific connection string for this activity"
    t.bigint "target_object_id", comment: "Target business object to apply the template"
    t.json "parameters", comment: "Specify parameters for the activity"
    t.bigint "node_type_id", default: 0, comment: "Drives the node's behaviour"
    t.bigint "gsbpm_id", comment: "Associate GSBPM sub-process"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "attached_files", comment: "Specify attachments path and names"
    t.index ["business_process_id", "code"], name: "index_activities_on_code", unique: true
    t.index ["business_process_id"], name: "index_activities_on_business_process_id"
    t.index ["deputy_id"], name: "index_activities_on_deputy_id"
    t.index ["failure_next_id"], name: "index_activities_on_failure_next_id"
    t.index ["gsbpm_id"], name: "index_activities_on_gsbpm_id"
    t.index ["hierarchy"], name: "index_activities_on_hierarchy", unique: true
    t.index ["id"], name: "index_activities_on_id", unique: true
    t.index ["node_type_id"], name: "index_activities_on_node_type_id"
    t.index ["organisation_id"], name: "index_activities_on_organisation_id"
    t.index ["owner_id"], name: "index_activities_on_owner_id"
    t.index ["playground_id"], name: "index_activities_on_playground_id"
    t.index ["responsible_id"], name: "index_activities_on_responsible_id"
    t.index ["sort_code"], name: "index_activities_on_sort_code"
    t.index ["status_id"], name: "index_activities_on_status_id"
    t.index ["success_next_id"], name: "index_activities_on_success_next_id"
    t.index ["target_object_id"], name: "index_activities_on_target_object_id"
    t.index ["technology_id"], name: "index_activities_on_technology_id"
    t.index ["template_id"], name: "index_activities_on_template_id"
    t.index ["uuid"], name: "index_activities_on_uuid"
  end

  create_table "annotations", id: :serial, comment: "Additional descriptive information", force: :cascade do |t|
    t.bigint "playground_id", null: false, comment: "Isolates tenants in a multi-tenancy configuration"
    t.string "object_extra_type", null: false
    t.bigint "object_extra_id", null: false, comment: "Object related to the annotation"
    t.bigint "annotation_type_id", null: false, comment: "Allows annotations quick filtering by type"
    t.string "code", limit: 255, null: false
    t.string "name", limit: 255
    t.text "description"
    t.string "uri", limit: 255
    t.string "sort_code", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annotation_type_id"], name: "index_annotations_on_annotation_type_id"
    t.index ["object_extra_type", "object_extra_id"], name: "index_annotations_on_object_extra_type_and_object_extra_id"
    t.index ["playground_id"], name: "index_annotations_on_playground_id"
    t.index ["sort_code"], name: "index_annotations_on_sort_code"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authorisations", id: :serial, comment: "Lists users tokens for several omniauth providers", force: :cascade do |t|
    t.bigint "user_id", comment: "User identified by the token"
    t.uuid "uid", null: false, comment: "User's uid in authetication system"
    t.string "provider", limit: 255, null: false, comment: "Authentication provider"
    t.string "token", limit: 255, null: false, comment: "Authentication token"
    t.string "secret", limit: 255, null: false, comment: "Authentication secret"
    t.string "profile_page", limit: 255, null: false, comment: "Landing page URL"
    t.string "profile_url", limit: 255, null: false, comment: "User profile URL"
    t.string "image_url", limit: 255, null: false, comment: "User picture URL"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_authorisations_on_uid"
    t.index ["user_id"], name: "index_authorisations_on_user_id"
  end

  create_table "business_areas", id: false, comment: "Provides the entry level of the business hierarchy. Describes the subject matter.", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('global_seq'::regclass)" }, null: false
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.string "pcf_index", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.string "pcf_reference", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.boolean "is_finalised", default: true, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deputy_id"], name: "index_business_areas_on_deputy_id"
    t.index ["hierarchy"], name: "index_ba_on_hierarchy", unique: true
    t.index ["id"], name: "index_ba_on_id", unique: true
    t.index ["organisation_id"], name: "index_business_areas_on_organisation_id"
    t.index ["owner_id"], name: "index_business_areas_on_owner_id"
    t.index ["playground_id", "code"], name: "index_ba_on_code", unique: true
    t.index ["playground_id"], name: "index_business_areas_on_playground_id"
    t.index ["responsible_id"], name: "index_business_areas_on_responsible_id"
    t.index ["sort_code"], name: "index_business_areas_on_sort_code"
    t.index ["status_id"], name: "index_business_areas_on_status_id"
    t.index ["uuid"], name: "index_business_areas_on_uuid"
  end

  create_table "business_flows", id: false, comment: "Logically groups consitent processses", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('global_seq'::regclass)" }, null: false
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_area_id"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.string "pcf_index", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.string "pcf_reference", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.boolean "is_finalised", default: true, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Start date of the activity"
    t.datetime "active_to", default: -> { "CURRENT_DATE" }, comment: "End date of the activity"
    t.text "legal_basis", comment: "Legal basis for the activity"
    t.bigint "collect_type_id", default: 0, comment: "Main collect method of the activity"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_area_id", "code"], name: "index_business_flows_on_code", unique: true
    t.index ["business_area_id"], name: "index_business_flows_on_business_area_id"
    t.index ["collect_type_id"], name: "index_business_flows_on_collect_type_id"
    t.index ["deputy_id"], name: "index_business_flows_on_deputy_id"
    t.index ["hierarchy"], name: "index_business_flows_on_hierarchy", unique: true
    t.index ["id"], name: "index_business_flows_on_id", unique: true
    t.index ["organisation_id"], name: "index_business_flows_on_organisation_id"
    t.index ["owner_id"], name: "index_business_flows_on_owner_id"
    t.index ["playground_id"], name: "index_business_flows_on_playground_id"
    t.index ["responsible_id"], name: "index_business_flows_on_responsible_id"
    t.index ["sort_code"], name: "index_business_flows_on_sort_code"
    t.index ["status_id"], name: "index_business_flows_on_status_id"
    t.index ["uuid"], name: "index_business_flows_on_uuid"
  end

  create_table "business_flows_organisations", id: :serial, comment: "Lists the organisations involved in the Business Flow", force: :cascade do |t|
    t.bigint "business_flow_id"
    t.bigint "organisation_id"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to", comment: "Universally unique identifier through organisations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_flow_id"], name: "index_business_flows_organisations_on_business_flow_id"
    t.index ["organisation_id"], name: "index_business_flows_organisations_on_organisation_id"
  end

  create_table "business_hierarchies", id: :serial, force: :cascade do |t|
    t.bigint "playground_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hierarchical_level"], name: "index_BH_on_level"
    t.index ["hierarchy"], name: "index_BH_on_hierarchy", unique: true
    t.index ["playground_id"], name: "index_business_hierarchies_on_playground_id"
  end

  create_table "business_objects", id: :serial, comment: "Describes an object in the scope of the business area, or elsewhere it is used", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.string "parent_type"
    t.bigint "parent_id", comment: "The Objet can exist at various abstraction levels, thus belonging to various parents"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.boolean "is_template", default: true, comment: "Flags the business object as a model to build other concepts - shortcut flag for abstraction_id"
    t.bigint "template_object_id", default: 0, comment: "References the business object used as template"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.text "external_description", comment: "Description used for external dissemination"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.integer "major_version", null: false
    t.integer "minor_version", null: false
    t.text "new_version_remark", comment: "When creating a new version, the user is prompted for the reason"
    t.boolean "is_published", default: true, comment: "The topic is published for external usage. Concepts used to build other objects (such as Address) are not published"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "period", limit: 255, comment: "The period these data relate to"
    t.bigint "ogd_id", default: 0, comment: "Open Governmental Data management"
    t.string "resource_file", limit: 255, comment: "Resource filename to provide these data"
    t.bigint "granularity_id", default: 0, comment: "Aggregation level covered by the dataset"
    t.string "physical_name", limit: 255, comment: "Physical name of the data object"
    t.bigint "technology_id", comment: "References the connection string for this object"
    t.string "resource_name", limit: 255, comment: "Name of the external file or web service used to store the master data"
    t.string "resource_list", limit: 255, comment: "List of master data identifiers to import"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.string "type", comment: "Type of business object: concept, deployed, acquired"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deputy_id"], name: "index_business_objects_on_deputy_id"
    t.index ["granularity_id"], name: "index_business_objects_on_granularity_id"
    t.index ["hierarchy", "major_version", "minor_version"], name: "index_business_objects_on_hierarchy", unique: true
    t.index ["id"], name: "index_business_objects_on_id", unique: true
    t.index ["ogd_id"], name: "index_business_objects_on_ogd_id"
    t.index ["organisation_id"], name: "index_business_objects_on_organisation_id"
    t.index ["owner_id"], name: "index_business_objects_on_owner_id"
    t.index ["parent_type", "parent_id", "code", "major_version", "minor_version"], name: "index_business_objects_on_code", unique: true
    t.index ["parent_type", "parent_id"], name: "index_business_objects_on_parent_type_and_parent_id"
    t.index ["playground_id"], name: "index_business_objects_on_playground_id"
    t.index ["responsible_id"], name: "index_business_objects_on_responsible_id"
    t.index ["sort_code"], name: "index_business_objects_on_sort_code"
    t.index ["status_id"], name: "index_business_objects_on_status_id"
    t.index ["technology_id"], name: "index_business_objects_on_technology_id"
    t.index ["template_object_id"], name: "index_business_objects_on_template_object_id"
    t.index ["uuid"], name: "index_business_objects_on_uuid"
  end

  create_table "business_objects_organisations", id: :serial, force: :cascade do |t|
    t.bigint "business_object_id"
    t.bigint "organisation_id"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_object_id"], name: "index_business_objects_organisations_on_business_object_id"
    t.index ["organisation_id"], name: "index_business_objects_organisations_on_organisation_id"
  end

  create_table "business_processes", id: false, comment: "Describes a process involving business objects and requiring business rules", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('global_seq'::regclass)" }, null: false
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_flow_id"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.string "pcf_index", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.string "pcf_reference", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.boolean "is_finalised", default: true, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.json "parameters", comment: "Specify parameters for process"
    t.bigint "gsbpm_id", comment: "Associate GSBPM process"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "attached_files", comment: "Specify attachments path and names"
    t.string "version", limit: 255, comment: "Version of the defined bunsiness process"
    t.index ["business_flow_id", "code"], name: "index_business_processes_on_code", unique: true
    t.index ["business_flow_id"], name: "index_business_processes_on_business_flow_id"
    t.index ["deputy_id"], name: "index_business_processes_on_deputy_id"
    t.index ["gsbpm_id"], name: "index_business_processes_on_gsbpm_id"
    t.index ["hierarchy"], name: "index_business_processes_on_hierarchy", unique: true
    t.index ["id"], name: "index_business_processes_on_id", unique: true
    t.index ["organisation_id"], name: "index_business_processes_on_organisation_id"
    t.index ["owner_id"], name: "index_business_processes_on_owner_id"
    t.index ["playground_id"], name: "index_business_processes_on_playground_id"
    t.index ["responsible_id"], name: "index_business_processes_on_responsible_id"
    t.index ["sort_code"], name: "index_business_processes_on_sort_code"
    t.index ["status_id"], name: "index_business_processes_on_status_id"
    t.index ["uuid"], name: "index_business_processes_on_uuid"
  end

  create_table "business_processes_organisations", id: :serial, comment: "Lists the organisations involved in the Business Process", force: :cascade do |t|
    t.bigint "business_process_id"
    t.bigint "organisation_id"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_process_id"], name: "index_business_processes_organisations_on_business_process_id"
    t.index ["organisation_id"], name: "index_business_processes_organisations_on_organisation_id"
  end

  create_table "business_rules", id: :serial, comment: "Describes a plausibilisation rule required to ensure the business process produces a consistent output", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_object_id", comment: "The rule applies to a business object involved in the business process"
    t.bigint "skill_id", comment: "The rule targets this skill, but can involve more in its description"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.integer "major_version", null: false
    t.integer "minor_version", null: false
    t.text "new_version_remark", comment: "When creating a new version, the user is prompted for the reason"
    t.boolean "is_published", default: true, comment: "The topic is published for external usage"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.string "evaluation_contexts", limit: 255, comment: "The rule may be available for a specific user action: update, data import, creation..."
    t.bigint "default_aggregation_id", default: 0, comment: "How to aggregate the count of records rejected due to this rule "
    t.string "ordering_sequence", limit: 255, comment: "provides a specific sequencing for rules execution when creating a data policy"
    t.text "business_value", comment: "Added value from the business point of view"
    t.text "check_description", comment: "Scenario for testing the plausibility of targeted data"
    t.text "check_script", comment: "The rule can be evaluated by a script writen in defined language hereunder"
    t.text "check_error_message", comment: "Additonnally to linked tasks, an error message can be raised"
    t.bigint "check_language_id", default: 0
    t.text "correction_method", comment: "Method description for solving the issue"
    t.text "correction_script", comment: "The rule can be corrected by a script writen in defined language hereunder"
    t.bigint "correction_language_id", default: 0
    t.text "white_list", comment: "List of records identifiers that should not be tested"
    t.float "added_value", default: 0.0, comment: "Metrics for assessment"
    t.float "maintenance_cost", default: 0.0, comment: "Metrics for assessment"
    t.float "maintenance_duration", default: 0.0, comment: "Metrics for assessment"
    t.bigint "duration_unit_id", default: 0, comment: "Unit of measure"
    t.bigint "rule_type_id", default: 0, comment: "Rule classification"
    t.bigint "severity_id", default: 0, comment: "Metrics for assessment"
    t.bigint "complexity_id", default: 0, comment: "Metrics for assessment"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the rule"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the rule"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the rule"
    t.integer "is_template", default: 1, comment: "Flags the rule as a model to build other rules"
    t.bigint "template_object_id", default: 0, comment: "References the rule used as template"
    t.bigint "rule_class_id", default: 0, comment: "Rule class from business classification"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_object_id", "code", "major_version", "minor_version"], name: "index_business_ruleson_code", unique: true
    t.index ["business_object_id"], name: "index_business_rules_on_business_object_id"
    t.index ["check_language_id"], name: "index_business_rules_on_check_language_id"
    t.index ["complexity_id"], name: "index_business_rules_on_complexity_id"
    t.index ["correction_language_id"], name: "index_business_rules_on_correction_language_id"
    t.index ["default_aggregation_id"], name: "index_business_rules_on_default_aggregation_id"
    t.index ["deputy_id"], name: "index_business_rules_on_deputy_id"
    t.index ["duration_unit_id"], name: "index_business_rules_on_duration_unit_id"
    t.index ["hierarchy", "major_version", "minor_version"], name: "index_business_ruleson_hierarchy", unique: true
    t.index ["id"], name: "index_business_rules_on_id", unique: true
    t.index ["organisation_id"], name: "index_business_rules_on_organisation_id"
    t.index ["owner_id"], name: "index_business_rules_on_owner_id"
    t.index ["playground_id"], name: "index_business_rules_on_playground_id"
    t.index ["responsible_id"], name: "index_business_rules_on_responsible_id"
    t.index ["rule_class_id"], name: "index_business_rules_on_rule_class_id"
    t.index ["rule_type_id"], name: "index_business_rules_on_rule_type_id"
    t.index ["severity_id"], name: "index_business_rules_on_severity_id"
    t.index ["skill_id"], name: "index_business_rules_on_skill_id"
    t.index ["sort_code"], name: "index_business_rules_on_sort_code"
    t.index ["status_id"], name: "index_business_rules_on_status_id"
    t.index ["template_object_id"], name: "index_business_rules_on_template_object_id"
  end

  create_table "classifications", id: :serial, comment: "Describes a hierarchy of values based on values-lists, such as a value set, a classification, an historised list, or a transcoding table.", force: :cascade do |t|
    t.bigint "playground_id_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_area_id", null: false
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the classification"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the classification"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the classification"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.bigint "type_id", default: 0, comment: "The type describes the usage of the hierarchy: value set, classification, historisation, mapping"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.integer "major_version", null: false
    t.integer "minor_version", null: false
    t.text "new_version_remark", comment: "When creating a new version, the user is prompted for the reason"
    t.boolean "is_published", default: true, comment: "The topic is published for external usage. Concepts used to build other objects (such as Address) are not published"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "workflow_state"
    t.json "anything"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_area_id", "code", "major_version", "minor_version"], name: "index_classification_on_code", unique: true
    t.index ["business_area_id"], name: "index_classifications_on_business_area_id"
    t.index ["deputy_id"], name: "index_classifications_on_deputy_id"
    t.index ["hierarchy", "major_version", "minor_version"], name: "index_classification_on_hierarchy", unique: true
    t.index ["id"], name: "index_classification_on_id", unique: true
    t.index ["organisation_id"], name: "index_classifications_on_organisation_id"
    t.index ["owner_id"], name: "index_classifications_on_owner_id"
    t.index ["playground_id_id"], name: "index_classifications_on_playground_id_id"
    t.index ["responsible_id"], name: "index_classifications_on_responsible_id"
    t.index ["sort_code"], name: "index_classifications_on_sort_code"
    t.index ["status_id"], name: "index_classifications_on_status_id"
    t.index ["type_id"], name: "index_classifications_on_type_id"
    t.index ["uuid"], name: "index_classifications_on_uuid"
  end

  create_table "data_policies", id: false, comment: "The Data Policy is a consistent group of rules to deploy in a specific context", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('global_seq'::regclass)" }, null: false
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_area_id"
    t.bigint "landscape_id"
    t.bigint "territory_id"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the policy"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the policy"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the policy"
    t.bigint "calendar_from_id"
    t.bigint "calendar_to_id"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.integer "major_version", null: false
    t.integer "minor_version", null: false
    t.text "new_version_remark", comment: "When creating a new version, the user is prompted for the reason"
    t.boolean "is_published", default: true, comment: "The topic is published for external usage"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "context_id", default: 0, comment: "Provides the context of execution of the policy (Dev, Test, Prod or other)"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_area_id"], name: "index_data_policies_on_business_area_id"
    t.index ["calendar_from_id"], name: "index_data_policies_on_calendar_from_id"
    t.index ["calendar_to_id"], name: "index_data_policies_on_calendar_to_id"
    t.index ["context_id"], name: "index_data_policies_on_context_id"
    t.index ["deputy_id"], name: "index_data_policies_on_deputy_id"
    t.index ["hierarchy", "major_version", "minor_version"], name: "index_data_policieson_hierarchy", unique: true
    t.index ["landscape_id"], name: "index_data_policies_on_landscape_id"
    t.index ["organisation_id"], name: "index_data_policies_on_organisation_id"
    t.index ["owner_id"], name: "index_data_policies_on_owner_id"
    t.index ["playground_id", "code", "major_version", "minor_version"], name: "index_data_policieson_code", unique: true
    t.index ["playground_id"], name: "index_data_policies_on_playground_id"
    t.index ["responsible_id"], name: "index_data_policies_on_responsible_id"
    t.index ["sort_code"], name: "index_data_policies_on_sort_code"
    t.index ["status_id"], name: "index_data_policies_on_status_id"
    t.index ["territory_id"], name: "index_data_policies_on_territory_id"
  end

  create_table "data_policy_links", id: false, comment: "Specifies which business rules to apply for which scope within a data policy", force: :cascade do |t|
    t.bigint "business_rule_id"
    t.bigint "data_policy_id"
    t.index ["business_rule_id"], name: "index_data_policy_links_on_business_rule_id"
    t.index ["data_policy_id"], name: "index_data_policy_links_on_data_policy_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.bigint "territory_id", null: false
    t.bigint "organisation_id", null: false
    t.string "hierarchy_entry", limit: 255, comment: "Business hierarchy level to use as filter for group's scope"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_group_on_code", unique: true
    t.index ["organisation_id"], name: "index_groups_on_organisation_id"
    t.index ["owner_id"], name: "index_groups_on_owner_id"
    t.index ["sort_code"], name: "index_groups_on_sort_code"
    t.index ["status_id"], name: "index_groups_on_status_id"
    t.index ["territory_id"], name: "index_groups_on_territory_id"
  end

  create_table "groups_roles", id: :serial, force: :cascade do |t|
    t.bigint "parameter_id"
    t.bigint "group_id"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_groups_roles_on_group_id"
    t.index ["parameter_id"], name: "index_groups_roles_on_parameter_id"
  end

  create_table "groups_users", id: :serial, force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "user_id"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.boolean "is_principal", default: false, comment: "User's main group allows notificaions routing."
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "landscapes", id: :serial, comment: "Describes a subproject within the whole playground, allows the grouping of scopes to implement data plausibilisation for a consistent part of the project", force: :cascade do |t|
    t.bigint "playground_id", comment: "Parent playground is the highest level of project's hierarchy"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.boolean "is_finalised", default: true, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deputy_id"], name: "index_landscapes_on_deputy_id"
    t.index ["hierarchy"], name: "index_landscapes_on_hierarchy", unique: true
    t.index ["organisation_id"], name: "index_landscapes_on_organisation_id"
    t.index ["owner_id"], name: "index_landscapes_on_owner_id"
    t.index ["playground_id", "code"], name: "index_landscapes_on_code", unique: true
    t.index ["playground_id"], name: "index_landscapes_on_playground_id"
    t.index ["responsible_id"], name: "index_landscapes_on_responsible_id"
    t.index ["sort_code"], name: "index_landscapes_on_sort_code"
    t.index ["status_id"], name: "index_landscapes_on_status_id"
  end

  create_table "notifications", id: :serial, comment: "Notifications agregates incidents and request in a message queue", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.bigint "severity_id", null: false
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.datetime "expected_at"
    t.datetime "closed_at"
    t.bigint "responsible_id", null: false
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "topic_type"
    t.bigint "topic_id"
    t.string "workflow_state"
    t.bigint "deputy_id"
    t.bigint "organisation_id"
    t.string "name", limit: 255
    t.string "code", limit: 255
    t.boolean "is_active", default: true
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_time", order: :desc
    t.index ["deputy_id"], name: "index_notifications_on_deputy_id"
    t.index ["organisation_id"], name: "index_notifications_on_organisation_id"
    t.index ["owner_id"], name: "index_notifications_on_owner_id"
    t.index ["playground_id"], name: "index_notifications_on_playground_id"
    t.index ["responsible_id"], name: "index_notifications_on_responsible_id"
    t.index ["severity_id"], name: "index_notifications_on_severity_id"
    t.index ["sort_code"], name: "index_notifications_on_sort_code"
    t.index ["status_id"], name: "index_notifications_on_status_id"
    t.index ["topic_type", "topic_id"], name: "index_notifications_on_topic_type_and_topic_id"
  end

  create_table "old_passwords", force: :cascade do |t|
    t.string "encrypted_password", null: false
    t.string "password_archivable_type", null: false
    t.integer "password_archivable_id", null: false
    t.string "password_salt"
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.bigint "organisation_id"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.integer "organisation_level", default: 0
    t.string "hierarchy", limit: 255
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "parent_id"
    t.string "external_reference", limit: 255
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_organisationson_code", unique: true
    t.index ["external_reference"], name: "index_organisationson_ext_ref", unique: true
    t.index ["hierarchy"], name: "index_organisationson_hierarchy", unique: true
    t.index ["organisation_id"], name: "index_organisations_on_organisation_id"
    t.index ["owner_id"], name: "index_organisations_on_owner_id"
    t.index ["parent_id"], name: "index_organisations_on_parent_id"
    t.index ["sort_code"], name: "index_organisations_on_sort_code"
    t.index ["status_id"], name: "index_organisations_on_status_id"
    t.index ["uuid"], name: "index_organisations_on_uuid"
  end

  create_table "parameters", id: :serial, force: :cascade do |t|
    t.bigint "parameters_list_id"
    t.string "scope", limit: 255
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "property", limit: 255, null: false
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon", limit: 255, comment: "Icon representing the option associated to the parameter"
    t.string "style", limit: 255, comment: "CSS style associated to the parameter"
    t.integer "value", comment: "Value associated to the parameter"
    t.index ["parameters_list_id", "code"], name: "index_parameters_on_code", unique: true
    t.index ["parameters_list_id"], name: "index_parameters_on_parameters_list_id"
    t.index ["sort_code"], name: "index_parameters_on_sort_code"
  end

  create_table "parameters_lists", id: :serial, force: :cascade do |t|
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_parameters_lists_on_code", unique: true
    t.index ["owner_id"], name: "index_parameters_lists_on_owner_id"
    t.index ["sort_code"], name: "index_parameters_lists_on_sort_code"
    t.index ["status_id"], name: "index_parameters_lists_on_status_id"
  end

  create_table "playgrounds", id: :serial, comment: "The playground isolates tenants in a multi-tenancy configuration. It can provide an additional level to the business hierarchy.", force: :cascade do |t|
    t.bigint "playground_id", default: 0, comment: "Self reference for convinience"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.boolean "is_finalised", default: true, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_pg_on_code", unique: true
    t.index ["deputy_id"], name: "index_playgrounds_on_deputy_id"
    t.index ["hierarchy"], name: "index_pg_on_hierarchy", unique: true
    t.index ["id"], name: "index_pg_on_id", unique: true
    t.index ["organisation_id"], name: "index_playgrounds_on_organisation_id"
    t.index ["owner_id"], name: "index_playgrounds_on_owner_id"
    t.index ["responsible_id"], name: "index_playgrounds_on_responsible_id"
    t.index ["sort_code"], name: "index_playgrounds_on_sort_code"
    t.index ["status_id"], name: "index_playgrounds_on_status_id"
  end

  create_table "production_events", id: :serial, comment: "Traces the production flows execution", force: :cascade do |t|
    t.bigint "playground_id", null: false, comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "production_group_id", null: false, comment: "Production event belongs to a production group"
    t.bigint "predecessor_id", comment: "Traces the previous event in execution"
    t.bigint "target_object_id", comment: "Specify the target business object"
    t.bigint "task_id", null: false, comment: "Specify the running task"
    t.bigint "status_id", null: false, comment: "Specify the task status"
    t.datetime "started_at", comment: "Task start timestamp"
    t.datetime "reported_at", comment: "Task last report timestamp"
    t.datetime "ended_at", comment: "Task end timestamp"
    t.integer "source_records_count", default: 0, comment: "Number of records in the source"
    t.integer "processed_count", default: 0, comment: "Total records processed"
    t.integer "created_count", default: 0, comment: "Number of records created"
    t.integer "read_count", default: 0, comment: "Number of records read"
    t.integer "updated_count", default: 0, comment: "Number of records updated"
    t.integer "deleted_count", default: 0, comment: "Number of records deleted"
    t.integer "rejected_count", default: 0, comment: "Number of records rejected"
    t.integer "error_count", default: 0, comment: "Number of records errors"
    t.text "error_message", comment: "Last error message"
    t.bigint "technology_id", comment: "Instance where the production flow was executed (SAS, SAP, Oracle ...)"
    t.integer "execution_sequence", default: 0, comment: "Seen execution order of steps"
    t.text "statement", comment: "Actual statement executed on the defined technology"
    t.text "return_value", comment: "Feedback of the statement action"
    t.bigint "success_next_id", comment: "Links to the next task in case of success"
    t.bigint "failure_next_id", comment: "Links to the next task in case of failure"
    t.string "return_value_pattern", limit: 255, comment: "Format to expect fo return value"
    t.string "completion_message", limit: 255, comment: "Log completion message"
    t.string "params_file_path", limit: 255, comment: "Path to the parameters file"
    t.string "params_file_name", limit: 255, comment: "Parameters file name"
    t.bigint "statement_language_id", comment: "Statement language (OS specific )"
    t.string "git_hash", limit: 255, comment: "Version management reference"
    t.text "git_response", comment: "Version management folder analysis"
    t.bigint "node_type_id", comment: "Drives the node's behaviour"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.json "parameters", comment: "Specify parameters for the task"
    t.json "attached_files", comment: "Specify attachments path and names"
    t.json "contract_input", comment: "Identification and parmeters of the requesting Scheduler step"
    t.json "contract_output", comment: "Response and parmeters of the requested script"
    t.string "request_id", limit: 255, comment: "Request unique concatenated identifier"
    t.string "code", limit: 255, comment: "Code from the task"
    t.index ["failure_next_id"], name: "index_production_events_on_failure_next_id"
    t.index ["node_type_id"], name: "index_production_events_on_node_type_id"
    t.index ["playground_id"], name: "index_production_events_on_playground_id"
    t.index ["predecessor_id"], name: "index_production_events_on_predecessor_id"
    t.index ["predecessor_id"], name: "index_production_events_predecessor"
    t.index ["production_group_id"], name: "index_production_events_on_production_group_id"
    t.index ["started_at"], name: "index_production_events_on_started_at"
    t.index ["statement_language_id"], name: "index_production_events_on_statement_language_id"
    t.index ["status_id"], name: "index_production_events_on_status_id"
    t.index ["success_next_id"], name: "index_production_events_on_success_next_id"
    t.index ["target_object_id"], name: "index_production_events_on_target_object_id"
    t.index ["task_id"], name: "index_production_events_on_task_id"
    t.index ["technology_id"], name: "index_production_events_on_technology_id"
  end

  create_table "production_executions", id: :serial, comment: "links to the production flows iterations", force: :cascade do |t|
    t.bigint "playground_id", null: false, comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "production_job_id", null: false, comment: "Defines the job generating these events"
    t.bigint "environment_id", comment: "Defines in which context it is executed (Dev, Val, Prod or other)"
    t.bigint "status_id", null: false, comment: "Specify the task status"
    t.boolean "is_for_test", default: false, comment: "Flag to allow step by step execution and statements modification"
    t.datetime "started_at", comment: "Task start timestamp"
    t.datetime "reported_at", comment: "Task last report timestamp"
    t.datetime "ended_at", comment: "Task end timestamp"
    t.integer "source_records_count", default: 0, comment: "Number of records in the source"
    t.integer "processed_count", default: 0, comment: "Total records processed"
    t.integer "created_count", default: 0, comment: "Number of records created"
    t.integer "read_count", default: 0, comment: "Number of records read"
    t.integer "updated_count", default: 0, comment: "Number of records updated"
    t.integer "deleted_count", default: 0, comment: "Number of records deleted"
    t.integer "rejected_count", default: 0, comment: "Number of records rejected"
    t.integer "error_count", default: 0, comment: "Number of records errors"
    t.text "error_message", comment: "Last error message"
    t.json "parameters", comment: "Specify parameters for the execution"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["environment_id"], name: "index_production_executions_on_environment_id"
    t.index ["owner_id"], name: "index_production_executions_on_owner_id"
    t.index ["playground_id"], name: "index_production_executions_on_playground_id"
    t.index ["production_job_id"], name: "index_production_executions_on_production_job_id"
    t.index ["status_id"], name: "index_production_executions_on_status_id"
  end

  create_table "production_groups", id: :serial, comment: "Groups executions events toghether (deployed activity)", force: :cascade do |t|
    t.integer "playground_id", null: false, comment: "Isolates tenants in a multi-tenancy configuration"
    t.integer "production_job_id", null: false, comment: "Defines the job generating these events"
    t.integer "status_id", null: false, comment: "Specify the activity status"
    t.json "parameters", comment: "Specify parameters for the activity"
    t.json "attached_files", comment: "Specify attachments path and names"
    t.datetime "started_at", comment: "Activity start timestamp"
    t.datetime "reported_at", comment: "Activity last report timestamp"
    t.datetime "ended_at", comment: "Activity end timestamp"
    t.integer "sort_code", comment: "Helps ordering execution links"
    t.integer "execution_sequence", default: 0, comment: "Showa actual execution order"
    t.string "code", limit: 255, comment: "Code from the activity"
    t.index ["execution_sequence"], name: "index_production_groups_on_execution_sequence"
    t.index ["playground_id"], name: "index_production_groups_on_playground_id"
    t.index ["production_job_id"], name: "index_production_groups_on_production_job_id"
    t.index ["sort_code"], name: "index_production_groups_on_sort_code"
    t.index ["started_at"], name: "index_production_groups_on_started_at"
  end

  create_table "production_jobs", id: :serial, comment: "Instances the production flows execution", force: :cascade do |t|
    t.bigint "playground_id", null: false, comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_process_id", null: false, comment: "Production job is an instance of a defined business process"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.bigint "status_id", null: false, comment: "Defines the status of the job"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.uuid "business_flow_uuid", comment: "Unique identifier of the BusinessFlow (Statistical Activity)"
    t.json "parameters", comment: "Heritates parameters for the job"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "attached_files", comment: "Specify attachments path and names"
    t.string "version", limit: 255, comment: "Version of the deployed production job"
    t.index ["business_flow_uuid"], name: "index_production_jobs_on_business_flow_uuid"
    t.index ["business_process_id"], name: "index_production_jobs_on_business_process_id"
    t.index ["owner_id"], name: "index_production_jobs_on_owner_id"
    t.index ["playground_id"], name: "index_production_jobs_on_playground_id"
    t.index ["status_id"], name: "index_production_jobs_on_status_id"
  end

  create_table "production_schedules", id: :serial, comment: "Provides the planning to production flows execution", force: :cascade do |t|
    t.bigint "playground_id", null: false, comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "production_job_id", null: false, comment: "Specify the process to be executed"
    t.bigint "environment_id", comment: "Defines in which context it is executed (Dev, Val, Prod or other)"
    t.bigint "mode_id", comment: "Scheduling mode (Test, at date, queue, interval)"
    t.string "code", limit: 255, comment: "Small information label for the schedule"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.bigint "status_id", default: 1, comment: "Active or Inactive flag"
    t.integer "repeat_value", default: 0, comment: "Run x times based on this value"
    t.integer "repeat_interval", comment: "Repetition interval value"
    t.integer "run_on_nth", comment: "Nth day for repetition"
    t.bigint "run_on_day_id", comment: "Day for execution"
    t.bigint "period_type_id_id", comment: "Periodicity"
    t.bigint "within_period_id_id", comment: "Time period for repetition"
    t.bigint "repeat_interval_unit_id", comment: "Repetition interval type (count, day, week, mont, year)"
    t.integer "repeat_counter", default: 0, comment: "Counts the number of executions"
    t.datetime "last_run", comment: "Last execution date and time"
    t.datetime "next_run", comment: "Next execution date and time"
    t.datetime "average_duration", comment: "Indicator of average executionduration"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.json "parameters", comment: "Override parameters for the schedule"
    t.string "queue_name", comment: "RabbitMQ queue name"
    t.string "queue_exchange", comment: "RabbitMQ message provider"
    t.string "queue_key", comment: "RabbitMQ queue key"
    t.json "queue_payload", comment: "RabbitMQ queue message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_identifier", limit: 255, comment: "Name of the parameter used as identifier in the message Payload"
    t.index ["environment_id"], name: "index_production_schedules_on_environment_id"
    t.index ["mode_id"], name: "index_production_schedules_on_mode_id"
    t.index ["owner_id"], name: "index_production_schedules_on_owner_id"
    t.index ["period_type_id_id"], name: "index_production_schedules_on_period_type_id_id"
    t.index ["playground_id"], name: "index_production_schedules_on_playground_id"
    t.index ["production_job_id"], name: "index_production_schedules_on_production_job_id"
    t.index ["queue_exchange", "queue_key", "mode_id"], name: "index_production_schedules_on_queueKey"
    t.index ["repeat_interval_unit_id"], name: "index_production_schedules_on_repeat_interval_unit_id"
    t.index ["run_on_day_id"], name: "index_production_schedules_on_run_on_day_id"
    t.index ["status_id"], name: "index_production_schedules_on_status_id"
    t.index ["within_period_id_id"], name: "index_production_schedules_on_within_period_id_id"
  end

  create_table "rules_for_processes", id: false, comment: "This table links business_rules to business_processes within a Data Policy", force: :cascade do |t|
    t.bigint "playground_id"
    t.bigint "business_rule_id"
    t.bigint "business_process_id"
    t.bigint "data_policy_id"
    t.index ["business_process_id"], name: "index_rules_for_processes_on_business_process_id"
    t.index ["business_rule_id"], name: "index_rules_for_processes_on_business_rule_id"
    t.index ["data_policy_id"], name: "index_rules_for_processes_on_data_policy_id"
    t.index ["playground_id", "data_policy_id"], name: "index_rfp_on_policy"
    t.index ["playground_id"], name: "index_rules_for_processes_on_playground_id"
  end

  create_table "scopes", id: :serial, comment: "Describes the technical methodology to build the dataset related to the business process and requiring plausibilisation", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_object_id"
    t.bigint "landscape_id"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.integer "major_version", null: false
    t.integer "minor_version", null: false
    t.text "new_version_remark", comment: "When creating a new version, the user is prompted for the reason"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.string "load_interface", limit: 255
    t.string "connection_string", limit: 255
    t.string "structure_name", limit: 255
    t.text "query"
    t.string "resource_file", limit: 255, comment: "Path to source file name"
    t.boolean "is_validated", default: false, comment: "Marks a scope with successfull data validation"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_object_id"], name: "index_scopes_on_business_object_id"
    t.index ["code", "major_version", "minor_version"], name: "index_scope_on_code"
    t.index ["deputy_id"], name: "index_scopes_on_deputy_id"
    t.index ["hierarchy", "major_version", "minor_version"], name: "index_scope_on_hierarchy", unique: true
    t.index ["landscape_id"], name: "index_scopes_on_landscape_id"
    t.index ["organisation_id"], name: "index_scopes_on_organisation_id"
    t.index ["owner_id"], name: "index_scopes_on_owner_id"
    t.index ["playground_id"], name: "index_scopes_on_playground_id"
    t.index ["responsible_id"], name: "index_scopes_on_responsible_id"
    t.index ["sort_code"], name: "index_scopes_on_sort_code"
    t.index ["status_id"], name: "index_scopes_on_status_id"
  end

  create_table "skills", id: :serial, comment: "Skills are the attributes of a Business Object", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_object_id"
    t.string "code", limit: 255, null: false, comment: "The code represents the physical column name of described dataset"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.text "external_description", comment: "Description used for external dissemination"
    t.boolean "is_template", default: true, comment: "The skill defines a concept"
    t.bigint "template_skill_id", default: 0, comment: "Reference to the skill from the standard object used to define this data element"
    t.bigint "skill_type_id", default: 0, comment: "Datatype from available types list"
    t.bigint "skill_aggregation_id", default: 0, comment: "Default aggregation behaviour"
    t.integer "skill_min_size", default: 0, comment: "Minimum size for content"
    t.integer "skill_size", comment: "Maximum size for content"
    t.integer "skill_precision", comment: "Number of digits after decimal point"
    t.bigint "skill_unit_id", default: 0, comment: "Unit of measure"
    t.bigint "skill_role_id", default: 0, comment: "Role assigned to the skill when it is used (key, dimension, measure, attribute)"
    t.boolean "is_mandatory", default: false, comment: "Flads the skill as mandatory, null or empty values will be rejected at validation"
    t.boolean "is_array", default: false, comment: "The skill can store several values"
    t.boolean "is_pk", default: false, comment: "The skill contributes to the primary key of the record"
    t.boolean "is_ak", default: false, comment: "The skill contributes to build an alternate key or business key for the record"
    t.boolean "is_published", default: true, comment: "Lets the skill visible for external users"
    t.boolean "is_multilingual", default: false, comment: "The skill contains a hash of values in several languages"
    t.bigint "sensitivity_id", default: 0
    t.bigint "status_id", default: 0, comment: "Status supports review process at skill level"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.string "regex_pattern", limit: 255, comment: "Valid value pattern"
    t.string "min_value", limit: 255, comment: "Minimum value allowed"
    t.string "max_value", limit: 255, comment: "Maximum value allowed"
    t.string "created_by", limit: 255, null: false
    t.string "updated_by", limit: 255, null: false
    t.boolean "is_pairing_key", default: false, comment: "This key can be used for record association"
    t.bigint "source_type_id", default: 0, comment: "Method used for data acquisition"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the data"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the data"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the data"
    t.json "anything"
    t.bigint "values_list_id"
    t.bigint "classification_id"
    t.string "type"
    t.string "filter", limit: 255, comment: "Filter expression for the allowed values list (reference)"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.string "physical_name", limit: 255, comment: "Physical name of the variable in the database.\n                                                                      Usually, the variable's code is used, but in the case of existing tables,\n                                                                      the physical name ensures backward compatibility."
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_object_id", "code"], name: "index_skills_on_code", unique: true
    t.index ["business_object_id"], name: "index_skills_on_business_object_id"
    t.index ["classification_id"], name: "index_skills_on_classification_id"
    t.index ["deputy_id"], name: "index_skills_on_deputy_id"
    t.index ["organisation_id"], name: "index_skills_on_organisation_id"
    t.index ["owner_id"], name: "index_skills_on_owner_id"
    t.index ["playground_id"], name: "index_skills_on_playground_id"
    t.index ["responsible_id"], name: "index_skills_on_responsible_id"
    t.index ["sensitivity_id"], name: "index_skills_on_sensitivity_id"
    t.index ["skill_aggregation_id"], name: "index_skills_on_skill_aggregation_id"
    t.index ["skill_role_id"], name: "index_skills_on_skill_role_id"
    t.index ["skill_type_id"], name: "index_skills_on_skill_type_id"
    t.index ["skill_unit_id"], name: "index_skills_on_skill_unit_id"
    t.index ["sort_code"], name: "index_skills_on_sort_code"
    t.index ["source_type_id"], name: "index_skills_on_source_type_id"
    t.index ["status_id"], name: "index_skills_on_status_id"
    t.index ["template_skill_id"], name: "index_skill_on_template_skill"
    t.index ["template_skill_id"], name: "index_skills_on_template_skill_id"
    t.index ["uuid"], name: "index_skills_on_uuid"
    t.index ["values_list_id"], name: "index_skills_on_values_list_id"
  end

  create_table "skills_values_lists", id: :serial, force: :cascade do |t|
    t.bigint "skill_id"
    t.bigint "values_list_id"
    t.bigint "playground_id", default: 0, null: false, comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "type_id", default: 0, comment: "Type of link to the skill (masterdata, quality, methodology...)"
    t.string "filter", limit: 255, comment: "Filter expression for the linked values_list"
    t.text "description", comment: "Description of link"
    t.index ["playground_id"], name: "index_skills_values_lists_on_playground_id"
    t.index ["skill_id"], name: "index_skills_values_lists_on_skill_id"
    t.index ["type_id"], name: "index_skills_values_lists_on_type_id"
    t.index ["values_list_id"], name: "index_skills_values_lists_on_values_list_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tasks", id: false, comment: "Describes the smallest item to realise within a activity", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('global_seq'::regclass)" }, null: false
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.string "parent_type"
    t.bigint "parent_id", comment: "The task can exist in an activity, or describe measures related to a business rule or an incident"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.string "pcf_index", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.string "pcf_reference", limit: 255, comment: "Reference to an external Process Classification Framework, such as APQC's"
    t.bigint "task_type_id", default: 0
    t.text "script", comment: "The task can be executed by a script writen in defined language hereunder"
    t.bigint "script_language_id", default: 0, comment: "Programming language used for sepcifying the task."
    t.string "external_reference", limit: 255, comment: "Reference to an external process"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.boolean "is_finalised", default: true, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.bigint "success_next_id", comment: "Links to the next activity in case of success"
    t.bigint "failure_next_id", comment: "Links to the next activity in case of failure"
    t.boolean "is_synchro", comment: "Waits for all preceeding tasks to complete before starting"
    t.boolean "is_template", default: false, comment: "Flags the task as template"
    t.bigint "template_id", comment: "Id of the task used as template"
    t.bigint "technology_id", comment: "References a specific connection string for this task"
    t.bigint "target_object_id", comment: "Target business object to apply the template"
    t.string "script_path", limit: 255, comment: "Path to the script location"
    t.string "git_hash", limit: 255, comment: "Version management reference"
    t.json "parameters", comment: "Specify parameters for task"
    t.bigint "node_type_id", default: 0, comment: "Drives the node's behaviour"
    t.string "script_name", limit: 255, comment: "Name of the script to execute"
    t.string "return_value_pattern", limit: 255, comment: "Format to expect for the statement's return value"
    t.text "statement", comment: "Statement to execute (to run a script)"
    t.bigint "statement_language_id", comment: "Statement language (OS specific )"
    t.bigint "gsbpm_id", comment: "Associate GSBPM sub-process"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "attached_files", comment: "Specify attachments path and names"
    t.index ["deputy_id"], name: "index_tasks_on_deputy_id"
    t.index ["failure_next_id"], name: "index_tasks_on_failure_next_id"
    t.index ["gsbpm_id"], name: "index_tasks_on_gsbpm_id"
    t.index ["id"], name: "index_tasks_on_id", unique: true
    t.index ["node_type_id"], name: "index_tasks_on_node_type_id"
    t.index ["organisation_id"], name: "index_tasks_on_organisation_id"
    t.index ["owner_id"], name: "index_tasks_on_owner_id"
    t.index ["parent_type", "parent_id", "code"], name: "index_task_on_code", unique: true
    t.index ["parent_type", "parent_id"], name: "index_tasks_on_parent_type_and_parent_id"
    t.index ["playground_id"], name: "index_tasks_on_playground_id"
    t.index ["responsible_id"], name: "index_tasks_on_responsible_id"
    t.index ["script_language_id"], name: "index_tasks_on_script_language_id"
    t.index ["sort_code"], name: "index_tasks_on_sort_code"
    t.index ["statement_language_id"], name: "index_tasks_on_statement_language_id"
    t.index ["status_id"], name: "index_tasks_on_status_id"
    t.index ["success_next_id"], name: "index_tasks_on_success_next_id"
    t.index ["target_object_id"], name: "index_tasks_on_target_object_id"
    t.index ["task_type_id"], name: "index_tasks_on_task_type_id"
    t.index ["technology_id"], name: "index_tasks_on_technology_id"
    t.index ["template_id"], name: "index_tasks_on_template_id"
  end

  create_table "territories", id: :serial, force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "territory_id"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.integer "territory_level", default: 0
    t.string "hierarchy", limit: 255
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "parent_id"
    t.string "external_reference", limit: 255
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_territorieson_code", unique: true
    t.index ["external_reference"], name: "index_territorieson_ext_ref", unique: true
    t.index ["hierarchy"], name: "index_territorieson_hierarchy", unique: true
    t.index ["owner_id"], name: "index_territories_on_owner_id"
    t.index ["parent_id"], name: "index_territories_on_parent_id"
    t.index ["playground_id"], name: "index_territories_on_playground_id"
    t.index ["sort_code"], name: "index_territories_on_sort_code"
    t.index ["status_id"], name: "index_territories_on_status_id"
    t.index ["territory_id"], name: "index_territories_on_territory_id"
    t.index ["uuid"], name: "index_territories_on_uuid"
  end

  create_table "time_scales", primary_key: "period_id", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.integer "day_of_week"
    t.integer "day_of_month"
    t.integer "day_of_year"
    t.integer "week_of_year"
    t.integer "month_of_year"
    t.integer "year"
    t.string "period_month", limit: 6
    t.string "period_day", limit: 8
    t.date "period_date"
    t.datetime "period_timestamp"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playground_id", "period_month", "period_day"], name: "index_time_scales_on_period", unique: true
    t.index ["playground_id"], name: "index_time_scales_on_playground_id"
  end

  create_table "translations", id: :serial, force: :cascade do |t|
    t.string "document_type", null: false
    t.bigint "document_id", null: false
    t.string "field_name", limit: 255, null: false
    t.string "language", limit: 255, null: false
    t.text "translation"
    t.tsvector "searchable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_type", "document_id", "field_name", "language"], name: "index_translation_on_field", unique: true
    t.index ["document_type", "document_id"], name: "index_translations_on_document_type_and_document_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.bigint "organisation_id", comment: "The organisation the user belongs to."
    t.bigint "current_playground_id", default: 0, comment: "The playground actually viewed in multi-tenant configuration"
    t.string "external_directory_uri", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "name", limit: 255, comment: "Name is provided by first-name + last-name"
    t.string "user_name", limit: 255, null: false, comment: "User name is used for loging in"
    t.string "language", limit: 255, default: "en", comment: "User language used to diaply translated content"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.boolean "is_admin", default: false
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token", limit: 255
    t.datetime "locked_at"
    t.uuid "uuid", comment: "Uid from OmniAuth authentication service"
    t.string "provider", comment: "OmniAuth provider"
    t.string "external_roles", default: [], comment: "List of role provided through OmniAuth", array: true
    t.string "preferred_activities", default: [], comment: "List of options provided through OmniAuth", array: true
    t.string "favourite_url", limit: 100, comment: "Resource to display at user login"
    t.index ["current_playground_id"], name: "index_users_on_current_playground_id"
    t.index ["email", "provider"], name: "index_users_on_email_provider", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["owner_id"], name: "index_users_on_owner_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
    t.index ["uuid"], name: "index_users_on_uuid"
  end

  create_table "values", id: :serial, force: :cascade do |t|
    t.bigint "values_list_id"
    t.string "code", limit: 255, null: false, comment: "Code has to be unique in a hierarchical level"
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.integer "level", default: 0
    t.bigint "parent_id"
    t.string "alternate_code", limit: 255
    t.string "alias", limit: 255
    t.string "abbreviation", limit: 255
    t.json "anything"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.bigint "classification_id"
    t.bigint "owner_id"
    t.bigint "status_id"
    t.string "uri", comment: "Uniform Resource Identifier"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classification_id"], name: "index_values_on_classification_id"
    t.index ["owner_id"], name: "index_values_on_owner_id"
    t.index ["parent_id"], name: "index_values_on_parent_id"
    t.index ["sort_code"], name: "index_values_on_sort_code"
    t.index ["status_id"], name: "index_values_on_status_id"
    t.index ["uuid"], name: "index_values_on_uuid"
    t.index ["values_list_id", "code"], name: "index_values_on_code", unique: true
    t.index ["values_list_id"], name: "index_values_on_values_list_id"
  end

  create_table "values_lists", id: :serial, comment: "Values lists provide hierarchical lists of reference data", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "business_area_id"
    t.bigint "organisation_id", default: 0, comment: "Organisation who is responsible for the theme"
    t.bigint "responsible_id", default: 0, comment: "User who is responsible for the theme"
    t.bigint "deputy_id", default: 0, comment: "Deputy who is responsible for the theme"
    t.boolean "is_hierarchical", default: false
    t.integer "max_levels", default: 1, null: false
    t.string "code", limit: 255, null: false
    t.string "name", limit: 255, comment: "Name is translated, this field is only for fall-back"
    t.text "description", comment: "Description is translated, this field is only for fall-back"
    t.string "resource_name", limit: 255, comment: "Name of the external file or table used to store the master data"
    t.string "hierarchy", limit: 255, null: false, comment: "Generated sequence of counters that uniquely identifies an object in application's objects hierarchy"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.integer "major_version", null: false
    t.integer "minor_version", null: false
    t.text "new_version_remark"
    t.boolean "is_finalised", default: false, comment: "Mostly used with versionned objects, flags an object to be usable in production"
    t.boolean "is_current", default: true, comment: "Used with versionned objects, flags the current version of an object"
    t.boolean "is_active", default: true, comment: "As nothing can be deleted, flags objects removed from the knowledge base"
    t.bigint "status_id", default: 0, comment: "Status is used for validation workflow in some objects only"
    t.bigint "owner_id", null: false, comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false, comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false, comment: "Trace of the last user or process who updated the record"
    t.bigint "list_type_id", default: 0, comment: "Type of values_list (Masterdata, Quality, Infrastructure, or Methodology)"
    t.bigint "code_type_id", default: 0, comment: "Defines the type of index that should be used and validated."
    t.integer "code_max_length", default: 32, comment: "Defines the maximum length of the index value."
    t.json "anything"
    t.string "sort_code", limit: 255, comment: "Code used for sorting displayed indexes"
    t.uuid "uuid", comment: "Universally unique identifier through organisations"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_area_id", "code", "major_version", "minor_version"], name: "index_values_lists_on_code", unique: true
    t.index ["business_area_id"], name: "index_values_lists_on_business_area_id"
    t.index ["code_type_id"], name: "index_values_lists_on_code_type_id"
    t.index ["deputy_id"], name: "index_values_lists_on_deputy_id"
    t.index ["hierarchy", "major_version", "minor_version"], name: "index_values_lists_on_hierarchy", unique: true
    t.index ["id"], name: "index_values_lists_on_id", unique: true
    t.index ["list_type_id"], name: "index_values_lists_on_list_type_id"
    t.index ["organisation_id"], name: "index_values_lists_on_organisation_id"
    t.index ["owner_id"], name: "index_values_lists_on_owner_id"
    t.index ["playground_id"], name: "index_values_lists_on_playground_id"
    t.index ["responsible_id"], name: "index_values_lists_on_responsible_id"
    t.index ["sort_code"], name: "index_values_lists_on_sort_code"
    t.index ["status_id"], name: "index_values_lists_on_status_id"
    t.index ["uuid"], name: "index_values_lists_on_uuid"
  end

  create_table "values_lists_classifications", id: :serial, comment: "Links a classification to values-lists including filter and description", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "classification_id", null: false
    t.bigint "values_list_id", null: false
    t.text "description", null: false, comment: "Description of link"
    t.string "filter", limit: 255, comment: "Filter expression for the linked values_list"
    t.bigint "type_id", default: 0, comment: "The type of link"
    t.json "anything"
    t.integer "level", default: 0, null: false, comment: "Level in the classification hierarchy"
    t.index ["classification_id"], name: "index_values_lists_classifications_on_classification_id"
    t.index ["playground_id"], name: "index_values_lists_classifications_on_playground_id"
    t.index ["type_id"], name: "index_values_lists_classifications_on_type_id"
    t.index ["values_list_id"], name: "index_values_lists_classifications_on_values_list_id"
  end

  create_table "values_to_values", id: :serial, comment: "Links a classification to values-lists including filter and description", force: :cascade do |t|
    t.bigint "playground_id", comment: "Isolates tenants in a multi-tenancy configuration"
    t.bigint "classification_id", null: false
    t.bigint "values_list_id", null: false
    t.bigint "child_values_list_id", null: false
    t.bigint "value_id", null: false
    t.bigint "child_value_id", null: false
    t.string "code", limit: 255, null: false, comment: "Code for this link"
    t.string "name", limit: 255, comment: "Name of the event causing this link "
    t.text "description", comment: "Details the reasons for this link"
    t.datetime "active_from", default: -> { "CURRENT_DATE" }, comment: "Validity period"
    t.datetime "active_to"
    t.bigint "type_id", default: 0, comment: "The type of link"
    t.integer "sort_order", default: 0
    t.json "anything"
    t.index ["child_value_id"], name: "index_values_to_values_on_child_value_id"
    t.index ["child_values_list_id"], name: "index_values_to_values_on_child_values_list_id"
    t.index ["classification_id", "sort_order"], name: "index_classification_values_on_sort_order"
    t.index ["classification_id", "values_list_id"], name: "index_classification_values_on_values_list"
    t.index ["classification_id"], name: "index_values_to_values_on_classification_id"
    t.index ["playground_id"], name: "index_values_to_values_on_playground_id"
    t.index ["type_id"], name: "index_values_to_values_on_type_id"
    t.index ["value_id"], name: "index_values_to_values_on_value_id"
    t.index ["values_list_id"], name: "index_values_to_values_on_values_list_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "taggings", "tags"
end
