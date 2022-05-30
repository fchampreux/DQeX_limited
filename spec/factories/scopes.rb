# == Schema Information
#
# Table name: scopes
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  business_object_id :bigint
#  landscape_id       :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  status_id          :integer          default(0)
#  hierarchy          :string(255)      not null
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  load_interface     :string(255)
#  connection_string  :string(255)
#  structure_name     :string(255)
#  query              :text
#  resource_file      :string(255)
#  is_validated       :boolean          default(FALSE)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

#FactoryBot.factories.clear
FactoryBot.define do
  factory :scope do
    association :parent,  factory: :business_object
    playground_id       {0}
    name                {"Test Scope"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Scope used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    owner_id            {1}
    status_id           {0}
    major_version       {0}
    minor_version       {0}
  end
end
