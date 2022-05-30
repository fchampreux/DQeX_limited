class Monitoring < ActiveRecord::Migration[5.1]

  def change

### Create monitoring tables
# Calendar: time_scales
# Data Marts for analysis: dm_processes, dm_scopes, dm_activities, dim_time

    create_table "time_scales", primary_key: "period_id" do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.integer "day_of_week"
      t.integer "day_of_month"
      t.integer "day_of_year"
      t.integer "week_of_year"
      t.integer "month_of_year"
      t.integer "year"
      t.string "period_month",           limit: 6
      t.string "period_day",             limit: 8
      t.date "period_date"
      t.datetime "period_timestamp"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps

      t.index ["playground_id", "period_month", "period_day"], name: "index_time_scales_on_period", unique: true
    end

=begin #to be reworked
# Data Marts for analysis
   create_table "dqm_dwh.dm_processes", id: :serial do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.integer "dqm_object_id",                      null: false
      t.integer "dqm_parent_id",                      null: false
      t.string "dqm_object_name",        limit: 255
      t.string "dqm_object_code",        limit: 255
      t.string "dqm_object_url",         limit: 255
      t.integer "period_id",                          null: false
      t.string "period_day",             limit: 8
      t.references :organisation,                     null: false
      t.references :territory,                        null: false
      t.integer "all_records",                     default: 0
      t.integer "error_count",                     default: 0
      t.decimal "score",            precision: 5,  scale: 2,  default: 0
      t.decimal "workload",         precision: 12, scale: 2,  default: 0
      t.decimal "added_value",      precision: 12, scale: 2,  default: 0
      t.decimal "maintenance_cost", precision: 12, scale: 2,  default: 0
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps

      t.index ["playground_id", "dqm_object_id", "period_id"], name: "index_dm_processes_on_object", unique: true
    end

    create_table "dqm_dwh.dm_scopes", id: :serial do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.integer "dqm_object_id",                      null: false
      t.integer "dqm_parent_id",                      null: false
      t.string "dqm_object_name",        limit: 255
      t.string "dqm_object_code",        limit: 255
      t.string "dqm_object_url",         limit: 255
      t.integer "period_id",                          null: false
      t.string "period_day",             limit: 8
      t.references :organisation,                     null: false
      t.references :territory,                        null: false
      t.integer "all_records",                     default: 0
      t.integer "error_count",                     default: 0
      t.decimal "score",            precision: 5, scale: 2,  default: 0
      t.decimal "workload",         precision: 12, scale: 2,  default: 0
      t.decimal "added_value",      precision: 12, scale: 2,  default: 0
      t.decimal "maintenance_cost", precision: 12, scale: 2,  default: 0
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps

      t.index ["playground_id", "dqm_object_id", "period_id"], name: "index_dm_scopes_on_object", unique: true
    end

    create_table "dqm_dwh.dm_activities", id: :serial do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.integer "dqm_object_id",                      null: false
      t.integer "dqm_parent_id",                      null: false
      t.string "dqm_object_name",        limit: 255
      t.string "dqm_object_code",        limit: 255
      t.string "dqm_object_url",         limit: 255
      t.integer "period_id",                          null: false
      t.string "period_day",             limit: 8
      t.references :organisation,                     null: false
      t.references :territory,                        null: false
      t.integer "all_records",                     default: 0
      t.integer "error_count",                     default: 0
      t.decimal "score",            precision: 5, scale: 2,  default: 0
      t.decimal "workload",         precision: 12, scale: 2,  default: 0
      t.decimal "added_value",      precision: 12, scale: 2,  default: 0
      t.decimal "maintenance_cost", precision: 12, scale: 2,  default: 0
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps

      t.index ["playground_id", "dqm_object_id", "period_id"], name: "index_dm_activities_on_object", unique: true
    end

    create_table "dqm_dwh.dim_time", primary_key: "period_id", id: :integer,  default: nil do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.string "period",                 limit: 6
      t.string "period_day",             limit: 8
      t.date "period_date"
      t.datetime "period_timestamp"
      t.integer "day_of_month"
      t.integer "day_of_year"
      t.integer "day_number"
      t.integer "week_of_month"
      t.integer "week_of_year"
      t.integer "week_number"
      t.integer "month"
      t.string "month_name",             limit: 255
      t.integer "month_number"
      t.integer "trimester_of_year"
      t.integer "trimester_number"
      t.integer "semester_of_year"
      t.integer "semester_number"
      t.integer "year"
      t.integer "year_number"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps

      t.index ["playground_id", "period", "period_day"], name: "index_dim_time_on_period", unique: true
    end

=end

  create_table "notifications", id: :serial,        comment: "Notifications agregates incidents and request in a message queue", force: :cascade do |t|
    t.belongs_to :playground,                       comment: "Isolates tenants in a multi-tenancy configuration"
    t.text "description",                           comment: "Description is translated, this field is only for fall-back"
    t.references :severity,           null: false
    t.references :status, default: 0, comment: "Status is used for validation workflow in some objects only"
    t.datetime "expected_at"
    t.datetime "closed_at"
    t.references :responsible,        null: false
    t.belongs_to :owner,               null: false,  comment: "All managed objects have a owner"
    t.string "created_by", limit: 255, null: false,  comment: "Trace of the user or process who created the record"
    t.string "updated_by", limit: 255, null: false,  comment: "Trace of the last user or process who updated the record"
    t.references :topic, polymorphic: true
    t.string "workflow_state"
    t.references :deputy
    t.references :organisation
    t.string "name",       limit: 255
    t.string "code",       limit: 255
    t.boolean "is_active", default: true
    t.string "sort_code",  limit: 255,               comment: "Code used for sorting displayed indexes"
    t.timestamps

    t.index ["created_at"], name: "index_notifications_on_time", order: :desc
    #t.index ["playground_id"], name: "index_notifications_on_playground_id"
    t.index ["sort_code"], name: "index_notifications_on_sort_code"
    #t.index ["topic_type", "topic_id"], name: "index_notifications_on_topic_type_and_topic_id"
  end


  end
end
