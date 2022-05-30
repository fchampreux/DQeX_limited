class AddScheduleIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :production_schedules, [:queue_exchange, :queue_key, :mode_id], name: "index_production_schedules_on_queueKey"
  end
end
