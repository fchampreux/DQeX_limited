# == Schema Information
#
# Table name: business_flows
#
#  id               :bigint           not null, primary key
#  playground_id    :bigint
#  business_area_id :bigint
#  organisation_id  :integer          default(0)
#  responsible_id   :integer          default(0)
#  deputy_id        :integer          default(0)
#  code             :string(255)      not null
#  name             :string(255)
#  description      :text
#  hierarchy        :string(255)      not null
#  pcf_index        :string(255)
#  pcf_reference    :string(255)
#  status_id        :integer          default(0)
#  is_finalised     :boolean          default(TRUE)
#  is_current       :boolean          default(TRUE)
#  is_active        :boolean          default(TRUE)
#  owner_id         :integer          not null
#  created_by       :string(255)      not null
#  updated_by       :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active_from      :datetime         default(Thu, 14 May 2020 10:49:30 UTC +00:00)
#  active_to        :datetime         default(Thu, 14 May 2020 10:49:30 UTC +00:00)
#  legal_basis      :text
#  collect_type_id  :integer          default(0)
#

#FactoryBot.factories.clear
FactoryBot.define do
  factory :business_flow do
    association :parent,  factory: :business_area
    playground_id       {0}
    name                {"Test Business Flow"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Business Flow used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    owner_id            {0}
    responsible_id      {0}
    deputy_id           {0}
    organisation_id     {0}
    status_id           {0}
  end
end
