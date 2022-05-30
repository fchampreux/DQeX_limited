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

require 'rails_helper'

RSpec.describe Notification, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:notification)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:title) }
		it { should validate_length_of(:title).is_at_most(200)}

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:notification)).to be_valid
  end
  it 'is invalid without a title' do
    expect(build(:notification, title: nil)).to_not be_valid
  end

end
