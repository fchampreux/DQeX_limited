# == Schema Information
#
# Table name: business_rules
#
#  id                     :bigint           not null, primary key
#  playground_id          :bigint
#  business_object_id     :bigint
#  skill_id               :bigint
#  code                   :string(255)      not null
#  name                   :string(255)
#  description            :text
#  hierarchy              :string(255)      not null
#  active_from            :datetime
#  active_to              :datetime
#  major_version          :integer          not null
#  minor_version          :integer          not null
#  new_version_remark     :text
#  is_published           :boolean          default(TRUE)
#  is_finalised           :boolean          default(FALSE)
#  is_current             :boolean          default(TRUE)
#  is_active              :boolean          default(TRUE)
#  evaluation_contexts    :string(255)
#  default_aggregation_id :integer          default(0)
#  ordering_sequence      :string(255)
#  business_value         :text
#  check_description      :text
#  check_script           :text
#  check_error_message    :text
#  check_language_id      :integer          default(0)
#  correction_method      :text
#  correction_script      :text
#  correction_language_id :integer          default(0)
#  added_value            :float            default(0.0)
#  maintenance_cost       :float            default(0.0)
#  maintenance_duration   :float            default(0.0)
#  duration_unit_id       :integer          default(0)
#  rule_type_id           :integer          default(0)
#  rule_class_id          :integer          default(0)
#  severity_id            :integer          default(0)
#  complexity_id          :integer          default(0)
#  status_id              :integer          default(0)
#  owner_id               :integer          not null
#  created_by             :string(255)      not null
#  updated_by             :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organisation_id        :integer          default(0)
#  responsible_id         :integer          default(0)
#  deputy_id              :integer          default(0)
#  is_template            :integer          default(1)
#  template_object_id     :integer          default(0)
#

#FactoryBot.factories.clear
FactoryBot.define do
  factory :business_rule do
    association :parent,  factory: :business_process
    playground_id       {0}
    name                {"Test Business Rule"}
    code                {Faker::Code.unique.rut}
    description         {"This is a test Business rule used for unit testing"}
    created_by          {"Fred"}
    updated_by          {"Fred"}
    owner_id            {1}
    status_id           {0}
    rule_type_id        {0}
    rule_category_id    {0}
    major_version       {0}
    minor_version       {0}
    severity_id         {0}
    complexity_id       {0}
#    responsible_id      {0}
#    deputy_id           {1}
#    organisation_id     {0}
  end
end
