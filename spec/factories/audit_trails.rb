# == Schema Information
#
# Table name: audits
#
#  id              :bigint           not null, primary key
#  auditable_id    :integer
#  auditable_type  :string
#  associated_id   :integer
#  associated_type :string
#  user_id         :integer
#  user_type       :string
#  username        :string
#  action          :string
#  audited_changes :text
#  version         :integer          default(0)
#  comment         :string
#  remote_address  :string
#  request_uuid    :string
#  created_at      :datetime
#


FactoryBot.define do
  factory :audit_trail do
    association :parent,  factory: :playground
    action              {"Test audit_trail"}
    description         {"This is a test used for unit testing"}
    created_by          {"Fred"}
    created_at          {Time.now}
    object_class        {"Object type"}
    object_name         {"My object"}
    server_name         {"My server"}
    object_id           {0}
  end
end
