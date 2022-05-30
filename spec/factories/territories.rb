# == Schema Information
#
# Table name: territories
#
#  id                 :integer          not null, primary key
#  playground_id      :bigint
#  territory_id       :bigint
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  territory_level    :integer          default(0)
#  hierarchy          :string(255)
#  status_id          :integer          default(0)
#  parent_id          :integer
#  external_reference :string(255)
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :territory do
    association :playground,  factory: :playground
    code              {Faker::Code.unique.rut}
    name              {"Test Territory"}
    description       {"Territory used for unit testing"}
    status_id         {0}
    created_by        {"Fred-te"}
    updated_by        {"Fred-te"}
    owner_id          {0}
  end
end
