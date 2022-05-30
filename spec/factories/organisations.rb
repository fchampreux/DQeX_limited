# == Schema Information
#
# Table name: organisations
#
#  id                 :integer          not null, primary key
#  playground_id      :bigint
#  organisation_id    :bigint
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  organisation_level :integer          default(0)
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
  factory :organisation do
    association :playground,  factory: :playground
    name              {"Test Organisation"}
    code              {Faker::Code.unique.rut}
    description       {"Organisation used for unit testing"}
    created_by        {"Fred-org"}
    updated_by        {"Fred-org"}
    status_id         {0}
    owner_id          {0}
  end
end
