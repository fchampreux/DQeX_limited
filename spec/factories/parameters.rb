# == Schema Information
#
# Table name: parameters
#
#  id                 :integer          not null, primary key
#  parameters_list_id :bigint
#  playground_id      :bigint
#  scope              :string(255)
#  name               :string(255)
#  code               :string(255)      not null
#  property           :string(255)      not null
#  description        :text
#  active_from        :datetime
#  active_to          :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :parameter do
    association :parent,  factory: :parameters_list
    name                      {"Test Parameter"}
    code                      {Faker::Code.unique.rut}
    property                  {"TEST"}
    description               {"This is a Test Parameter for unit testing"}
    active_from               {"2001-01-01"}
    active_to                 {"2100-01-01"}
  end
end
