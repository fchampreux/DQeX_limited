# == Schema Information
#
# Table name: parameters_lists
#
#  id            :integer          not null, primary key
#  playground_id :bigint
#  code          :string(255)      not null
#  name          :string(255)
#  description   :text
#  is_active     :boolean          default(TRUE)
#  status_id     :integer          default(0)
#  owner_id      :integer          not null
#  created_by    :string(255)      not null
#  updated_by    :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :parameters_list do
    association :parent,  factory: :playground
    name                      {"Test Parameters list"}
    code                      {Faker::Code.unique.rut}
    description               {"This is a Test Parameters list for unit testing"}
    created_by                {"Fred"}
    updated_by                {"Fred"}
    owner_id                  {1}
    status_id                 {0}
  end
end
