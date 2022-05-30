# == Schema Information
#
# Table name: activities
#
#  id                  :bigint           not null, primary key
#  playground_id       :bigint
#  business_process_id :bigint
#  organisation_id     :integer          default(0)
#  responsible_id      :integer          default(0)
#  deputy_id           :integer          default(0)
#  code                :string(255)      not null
#  name                :string(255)
#  description         :text
#  hierarchy           :string(255)      not null
#  status_id           :integer          default(0)
#  pcf_index           :string(255)
#  pcf_reference       :string(255)
#  is_finalised        :boolean          default(FALSE)
#  is_current          :boolean          default(TRUE)
#  is_active           :boolean          default(TRUE)
#  owner_id            :integer          not null
#  created_by          :string(255)      not null
#  updated_by          :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

RSpec.describe Activity, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:activity)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).scoped_to(:business_process_id).case_insensitive }
    it { should validate_length_of(:code).is_at_most(32)}
		it { should validate_length_of(:pcf_index).is_at_most(30)}
		it { should validate_length_of(:pcf_reference).is_at_most(100)}
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:activity)).to be_valid
  end
  it 'is invalid without a status' do
    expect(build(:activity, status_id: nil)).to_not be_valid
  end


end
