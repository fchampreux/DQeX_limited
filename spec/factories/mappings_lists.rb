# == Schema Information
#
# Table name: mappings_lists
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  business_area_id   :bigint
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  source_list_id     :integer          not null
#  target_list_id     :integer          not null
#  hierarchy          :string(255)      not null
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  status_id          :integer          default(0)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :mappings_list do
    association :parent,  factory: :business_area
    association :source_list,  factory: :values_list
    association :target_list,  factory: :values_list
    playground_id     {0}
    code              {Faker::Code.unique.rut}
    name              {"Test Mappings list"}
    description       {"This is a Test Mappings list for unit testing"}
    source_list_id    {0}
    target_list_id    {0}
    major_version     {0}
    minor_version     {0}
    owner_id          {1}
    status_id         {0}
    responsible_id    {1}
    deputy_id         {1}
    organisation_id   {0}
    created_by        {"Fred"}
    updated_by        {"Fred"}
  end
end
