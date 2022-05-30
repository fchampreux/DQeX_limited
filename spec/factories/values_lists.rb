# == Schema Information
#
# Table name: values_lists
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  business_area_id   :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  ressource_name     :string(255)
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
#  anything           :json
#  workflow_state     :string
#  type_id            :integer          default(0)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :values_list do
    association :parent,  factory: :business_area
    playground_id       {0}
    name                {"Test Values Lists"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Values Lists used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    owner_id            {1}
    status_id           {0}
    major_version       {0}
    minor_version       {0}
    responsible_id      {1}
    deputy_id           {1}
    organisation_id     {0}
      factory :values do
        values_list
      end
    end
end
