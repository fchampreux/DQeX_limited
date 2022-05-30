# == Schema Information
#
# Table name: data_policies
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  business_area_id   :bigint
#  landscape_id       :bigint
#  territory_id       :bigint
#  organisation_id    :bigint
#  calendar_from_id   :bigint
#  calendar_to_id     :bigint
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_published       :boolean          default(TRUE)
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  status_id          :integer          default(0)
#  context_id         :integer          default(0)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#


    FactoryBot.define do
      factory :data_policy do
        association :parent,  factory: :business_area
        playground_id       {0}
        name                {"Test Activity"}
        code                {Faker::Code.unique.rut}
        description         {"This is a test Activity used for unit testing"}
        created_by          {"Fred"}
        updated_by          {"Fred"}
        owner_id            {1}
        status_id           {0}
        major_version       {0}
        minor_version       {0}
        territory_id        {0}
        organisation_id     {0}
        active_from         {Time.now}
      end
    end
