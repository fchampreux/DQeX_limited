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

require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:user) }
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:organisation_id) }
    it { should validate_presence_of(:user_name) }
    it { should validate_length_of(:user_name).is_at_most(30) }
    it { should validate_uniqueness_of(:user_name).case_insensitive.scoped_to(:playground_id) }
    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:last_name).is_at_most(100) }
    it { should validate_length_of(:first_name).is_at_most(100) }
    it { should validate_length_of(:external_directory_id).is_at_most(100) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }
    it { should validate_presence_of(:default_playground_id) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end
  it 'is invalid without a user name' do
    expect(build(:user, user_name: nil)).to_not be_valid
  end


end
