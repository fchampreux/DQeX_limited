# == Schema Information
#
# Table name: landscapes
#
#  id              :bigint           not null, primary key
#  playground_id   :bigint
#  organisation_id :integer          default(0)
#  responsible_id  :integer          default(0)
#  deputy_id       :integer          default(0)
#  code            :string(255)      not null
#  name            :string(255)
#  description     :text
#  hierarchy       :string(255)      not null
#  status_id       :integer          default(0)
#  is_finalised    :boolean          default(TRUE)
#  is_current      :boolean          default(TRUE)
#  is_active       :boolean          default(TRUE)
#  owner_id        :integer          not null
#  created_by      :string(255)      not null
#  updated_by      :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

#FactoryBot.factories.clear
FactoryBot.define do
  factory :landscape do
    association :parent,  factory: :playground
    name                {"Test Lanscape"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Landscape used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    owner_id            {1}
    status_id           {0}
  end
end
