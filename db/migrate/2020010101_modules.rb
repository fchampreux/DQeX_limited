class Modules < ActiveRecord::Migration[5.1]

  def change

### Create gem modules support tables
  # Active storage: active_storage_blobs, active_storage_attachments
  # Acts as taggable: tags, taggings
  # Devise passwords history: old_passwords
  # Auditable: audits

  # Active storage: active_storage_blobs, active_storage_attachments
    create_table :active_storage_blobs do |t|
      t.string   :key,         null: false
      t.string   :filename,    null: false
      t.string   :content_type
      t.text     :metadata
      t.bigint   :byte_size,   null: false
      t.string   :checksum,    null: false
      t.datetime :created_at,  null: false

      t.index [ :key ], unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string     :name,      null: false
      t.references :record,    null: false, polymorphic: true, index: false
      t.references :blob,      null: false
      t.datetime :created_at,  null: false

      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end

  # Acts as taggable: tags, taggings
    create_table "tags", id: :serial, force: :cascade do |t|
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "taggings_count", default: 0
      t.index ["name"], name: "index_tags_on_name", unique: true
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
      t.foreign_key "tags"
    end

# Devise passwords history: old_passwords
    create_table "old_passwords", force: :cascade do |t|
      t.string "encrypted_password", null: false
      t.string "password_archivable_type", null: false
      t.integer "password_archivable_id", null: false
      t.string "password_salt"
      t.datetime "created_at"
      
      t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
    end

# Auditable: audits
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer
      t.column :auditable_type, :string
      t.column :associated_id, :integer
      t.column :associated_type, :string
      t.column :user_id, :integer
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :audited_changes, :text
      t.column :version, :integer, :default => 0
      t.column :comment, :string
      t.column :remote_address, :string
      t.column :request_uuid, :string
      t.column :created_at, :datetime
    end

    add_index :audits, [:auditable_type, :auditable_id, :version], :name => 'auditable_index'
    add_index :audits, [:associated_type, :associated_id], :name => 'associated_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :request_uuid
    add_index :audits, :created_at

  end
end
