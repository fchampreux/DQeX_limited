# == Schema Information
#
# Table name: business_objects
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  parent_type        :string
#  parent_id          :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  is_template        :boolean          default(TRUE)
#  template_object_id :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  status_id          :integer          default(0)
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_published       :boolean          default(TRUE)
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  reviewed_by        :integer
#  reviewed_at        :datetime
#  approved_by        :integer
#  approved_at        :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  period             :string(255)
#  ogd_id             :integer          default(0)
#  resource_file      :string(255)
#  granularity_id     :integer
#

#FactoryBot.factories.clear
FactoryBot.define do
  factory :business_object do
    association :parent, factory: :business_area #, strategy: :build
    playground_id       {0}
    name                {"Test Business Object"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Business object used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    major_version       {0}
    minor_version       {0}
    owner_id            {1}
    status_id           {0}
    responsible_id      {1}
    deputy_id           {1}
    organisation_id     {0}
  end
end
