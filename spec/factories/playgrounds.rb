# == Schema Information
#
# Table name: playgrounds
#
#  id              :bigint           not null, primary key
#  playground_id   :bigint           default(0)
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
  factory :playground do
    playground_id       {0}
    name                {"Test Playground"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Playground used for unit testing"}
    created_by          {"Fred-PG"}
    updated_by          {"Fred-PG"}
    hierarchy           {"2.0"}
    status_id           {0}
    owner_id            {1}
    organisation_id     {0}
    responsible_id      {0}
    deputy_id           {0}
  end
end
