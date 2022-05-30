# == Schema Information
#
# Table name: groups
#
#  id              :integer          not null, primary key
#  playground_id   :bigint
#  code            :string(255)      not null
#  name            :string(255)
#  description     :text
#  territory_id    :integer          not null
#  organisation_id :integer          not null
#  is_active       :boolean          default(TRUE)
#  status_id       :integer          default(0)
#  owner_id        :integer          not null
#  created_by      :string(255)      not null
#  updated_by      :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  hierarchy_entry :string(255)
#

FactoryBot.define do
  factory :group do
    association :parent, factory: :playground
    name            {"Test group"}
    description     {"Group created for testing purpose"}
    code            {Faker::Code.unique.rut}
    territory_id    {0}
    organisation_id {0}
    status_id       {0}
    owner_id        {0}
    created_by      {"Fred"}
    updated_by      {"Fred"}
  end
end
