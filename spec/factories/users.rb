# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  playground_id          :bigint
#  organisation_id        :bigint
#  current_playground_id  :integer          default(1)
#  external_directory_id  :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  name                   :string(255)
#  user_name              :string(255)      not null
#  language               :string(255)      default("en")
#  description            :text
#  active_from            :datetime
#  active_to              :datetime
#  is_admin               :boolean          default(FALSE)
#  is_active              :boolean          default(TRUE)
#  owner_id               :integer
#  created_by             :string(255)      not null
#  updated_by             :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#

FactoryBot.define do
  sequence(:login) {|n| "user#{n}"}
  sequence(:email) {|n| "user#{n}@gmail.com"}
  factory :user do
    association :parent,  factory: :playground
    default_playground_id {0}
    owner_id              {0}
    organisation_id       {0}
    first_name          {"user"}
    last_name           {"test"}
    user_name           {generate :login}
    email               {generate :email}
    password            {"DQtest_user01"}
    password_confirmation {"DQtest_user01"}
    description         {"This is a test User used for unit testing"}
    created_by          {"Rspec"}
    updated_by          {"Rspec"}
    confirmed_at        {Time.now}
  end
end
