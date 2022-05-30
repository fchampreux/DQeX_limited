# == Schema Information
#
# Table name: dqm_dwh.dm_processes
#
#  id               :integer          not null, primary key
#  playground_id    :bigint
#  dqm_object_id    :integer          not null
#  dqm_parent_id    :integer          not null
#  dqm_object_name  :string(255)
#  dqm_object_code  :string(255)
#  dqm_object_url   :string(255)
#  period_id        :integer          not null
#  period_day       :string(8)
#  organisation_id  :integer          not null
#  territory_id     :integer          not null
#  all_records      :integer          default(0)
#  error_count      :integer          default(0)
#  score            :decimal(5, 2)    default(0.0)
#  workload         :decimal(12, 2)   default(0.0)
#  added_value      :decimal(12, 2)   default(0.0)
#  maintenance_cost :decimal(12, 2)   default(0.0)
#  created_by       :string(255)      not null
#  updated_by       :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class DmProcess < ApplicationRecord
  self.table_name = "dqm_dwh.dm_processes"
  
### scope
  scope :pgnd, ->(my_pgnd) { where "playground_id=? or ?", my_pgnd, $Unicity }

end


