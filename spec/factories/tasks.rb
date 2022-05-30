# == Schema Information
#
# Table name: tasks
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  parent_type        :string
#  parent_id          :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  pcf_index          :string(255)
#  pcf_reference      :string(255)
#  task_type_id       :integer          default(0)
#  script             :text
#  script_language_id :integer          default(0)
#  external_reference :string(255)
#  status_id          :integer          default(0)
#  owner_id           :integer          not null
#  is_finalised       :boolean          default(TRUE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryBot.define do
  factory :task do
    association :parent, factory: :activity
    playground_id       {0}
    name                {"Test Task"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Task used for unit testing"}
    owner_id            {1}
    status_id           {0}

  end
end
