# == Schema Information
#
# Table name: values
#
#  id             :integer          not null, primary key
#  values_list_id :bigint
#  code           :string(255)      not null
#  name           :string(255)
#  description    :text
#  level          :integer          default(1), not null
#  parent_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  playground_id  :bigint
#  alternate_code :string(255)
#  alias          :string(255)
#  abbreviation   :string(255)
#  anything       :json
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :value do
    association :parent,  factory: :values_list
    code              {Faker::Code.unique.rut}
    description       {"This is a test values list used for unit testing"}
    name              {"TEST values list"}
  end
end
