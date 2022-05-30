class IncidentManagement < ActiveRecord::Migration[5.1]

  def change

### Create incident management tables
# Incidents management: breaches

=begin #to be reworked
  # Incidents management :breaches
    create_table "breaches", id: :serial, comment: "This table collects error notifications for the follow-up process" do |t|
      t.belongs_to :playground,        index: true,                comment: "Isolates tenants in a multi-tenancy configuration"
      t.references :business_rule,     index: true
      t.references :business_object,   index: true
      t.references :time_scales,       index: true
      t.references :organisation,      index: true
      t.references :territory,         index: true
      t.integer "application_id",                     null: false
      t.text "pk_values",                limit: 4000, null: false
      t.integer "record_id",                          null: false
      t.string "title",                  limit: 255
      t.text "description",              limit: 4000,              comment: "Description is translated, this field is only for fall-back"
      t.integer "breach_type_id",                     null: false
      t.integer "breach_status_id",                   null: false
      t.integer "status_id",                       default: 0,     comment: "Status is used for validation workflow in some objects only"
      t.string "message_source",         limit: 255
      t.string "object_name",            limit: 255
      t.text "error_message",            limit: 4000
      t.text "current_values",           limit: 4000
      t.text "proposed_values",          limit: 4000
      t.boolean "is_whitelisted",                  default: false
      t.datetime "opened_at"
      t.datetime "expected_at"
      t.datetime "closed_at"
      t.integer "responsible_id"
      t.integer "approver_id"
      t.datetime "approved_at"
      t.string "record_updated_by",      limit: 255
      t.datetime "record_updated_at"
      t.integer "owner_id",                           null: false, comment: "All managed objects have a owner"
      t.boolean "is_identified",                   default: false
      t.integer "notification_id"
      t.string "created_by",             limit: 255,  null: false, comment: "Trace of the user or process who created the record"
      t.string "updated_by",             limit: 255,  null: false, comment: "Trace of the last user or process who updated the record"
      t.timestamps
      t.index ["created_at"], order: {created_at: :desc}, name: "index_breaches_on_time"
    end
=end
  end
end
