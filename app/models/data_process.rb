# == Schema Information
#
# Table name: data_processes
#
#  id                 :integer          not null, primary key
#  playground_id      :integer
#  name               :string(255)
#  description        :text
#  scope_id           :integer
#  business_object_id :integer
#  status_id          :integer
#  last_run_at        :datetime
#  next_run_at        :datetime
#  last_run_end       :datetime
#  duration           :decimal(, )
#  loaded             :integer
#  inserted           :integer
#  updated            :integer
#  deleted            :integer
#  rejected           :integer
#  owner_id           :integer
#  dqm_unique_id      :integer
#  dqm_object_id      :integer
#  created_by         :string(255)
#  updated_by         :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class DataProcess < ApplicationRecord
end
