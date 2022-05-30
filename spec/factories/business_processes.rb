# == Schema Information
#
# Table name: business_processes
#
#  id                   :bigint           not null, primary key
#  playground_id        :bigint
#  business_flow_id     :bigint
#  organisation_id      :integer          default(0)
#  responsible_id       :integer          default(0)
#  deputy_id            :integer          default(0)
#  code                 :string(255)      not null
#  name                 :string(255)
#  description          :text
#  hierarchy            :string(255)      not null
#  pcf_index            :string(255)
#  pcf_reference        :string(255)
#  status_id            :integer          default(0)
#  is_finalised         :boolean          default(TRUE)
#  is_current           :boolean          default(TRUE)
#  is_active            :boolean          default(TRUE)
#  owner_id             :integer          not null
#  created_by           :string(255)      not null
#  updated_by           :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_description :text
#

#FactoryBot.factories.clear
FactoryBot.define do
  factory :business_process do
    association :parent,  factory: :business_flow
    playground_id       {0}
    name                {"Test Business Process"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Business process used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    owner_id            {0}
    status_id           {0}
  end
end
