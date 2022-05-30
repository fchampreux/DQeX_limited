class RenameEventCounters < ActiveRecord::Migration[5.2]
  def change
    rename_column :production_events, :created, :created_count
    rename_column :production_events, :read, :read_count
    rename_column :production_events, :updated, :updated_count
    rename_column :production_events, :deleted, :deleted_count
    rename_column :production_events, :rejected, :rejected_count
  end
end
