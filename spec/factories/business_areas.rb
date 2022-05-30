# == Schema Information
#
# Table name: business_areas
#
#  id             :bigint           not null, primary key
#  playground_id  :bigint
#  responsible_id :integer          default(0)
#  deputy_id      :integer          default(0)
#  code           :string(255)      not null
#  name           :string(255)
#  description    :text
#  hierarchy      :string(255)      not null
#  pcf_index      :string(255)
#  pcf_reference  :string(255)
#  status_id      :integer          default(0)
#  is_finalised   :boolean          default(TRUE)
#  is_current     :boolean          default(TRUE)
#  is_active      :boolean          default(TRUE)
#  owner_id       :integer          not null
#  created_by     :string(255)      not null
#  updated_by     :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reviewer_id    :integer
#

#FactoryBot.factories.clear
FactoryBot.define do
  factory :business_area do
    association :parent,  factory: :playground
    name                {"Test Business Area"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Business Area used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    status_id           {0}
    owner_id            {0}
    responsible_id      {0}
    deputy_id           {0}
  end
end
