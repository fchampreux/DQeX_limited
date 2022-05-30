# == Schema Information
#
# Table name: mappings
#
#  id               :integer          not null, primary key
#  mappings_list_id :bigint
#  source_value_id  :integer
#  target_value_id  :integer
#  is_active        :boolean          default(TRUE)
#  active_from      :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :mapping do
    association :parent,  factory: :mappings_list
    source_software           {"Application"}
    source_table              {"Application"}
    source_code               {"Application"}
    source_property           {"Application"}
    target_software           {"Application"}
    target_code               {"Application"}
    target_table              {"Application"}
    target_property           {"Application"}
  end
end
