# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  playground_id   :bigint
#  description     :text
#  severity_id     :integer          not null
#  status_id       :integer          default(0)
#  expected_at     :datetime
#  closed_at       :datetime
#  responsible_id  :integer          not null
#  owner_id        :integer          not null
#  created_by      :string(255)      not null
#  updated_by      :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  topic_type      :string
#  topic_id        :bigint
#  workflow_state  :string
#  deputy_id       :integer
#  organisation_id :integer
#  name            :string(255)
#  code            :string(255)
#  is_active       :boolean          default(TRUE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :notification do
    playground_id       {0}
    title               {"Test notification"}
    description         {"This is a unit test"}
    created_by          {"RSpec"}
    updated_by          {"RSpec"}
    owner_id            {0}
    severity_id         {0}
    scope_id            {0}
    business_object_id  {0}
    expected_at         {Time.now}
    closed_at           {""}
    responsible_id      {0}
  end
end
