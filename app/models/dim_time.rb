# == Schema Information
#
# Table name: time_scales
#
#  period_id        :bigint           not null, primary key
#  playground_id    :bigint
#  day_of_week      :integer
#  day_of_month     :integer
#  day_of_year      :integer
#  week_of_year     :integer
#  month_of_year    :integer
#  year             :integer
#  period_month     :string(6)
#  period_day       :string(8)
#  period_date      :date
#  period_timestamp :datetime
#  created_by       :string(255)      not null
#  updated_by       :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class DimTime < ApplicationRecord
  self.table_name = "time_scales"

### scope
  scope :pgnd, ->(my_pgnd) { where "playground_id=? or ?", my_pgnd, $Unicity }

end
