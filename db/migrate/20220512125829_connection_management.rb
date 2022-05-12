class ConnectionManagement < ActiveRecord::Migration[5.2]
  def change
    create_table "connections", id: :serial do |t|
      t.string   :code,                        limit: 255   , comment: "Information based on elements'codes"
      t.references :database_schema,             index: true  , comment: "schemas hierarchical list"
      t.references :environment,                 index: true  , comment: "Environments hierarchical list"
      t.references :business_service,            index: true  , comment: "Business services hierarchical list"
      t.timestamps
    end

    # Authorisations: groups_connection
    create_table "groups_connections", id: :serial do |t|
      t.references :connection,           index: true
      t.references :group,                index: true
      t.boolean "is_active",                       default: true,  comment: "As nothing can be deleted, flags objects removed from the knowledge base"
      t.datetime "active_from",                    default: -> { 'current_date' }, comment: "Validity period"
      t.datetime "active_to"
      t.timestamps
    end
  end
end
