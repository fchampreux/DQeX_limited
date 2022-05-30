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

require 'rails_helper'

RSpec.describe Group, type: :model do
    describe 'Validations'
  subject {FactoryBot.build(:group)}
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code).scoped_to(:playground_id).case_insensitive }
  it { should validate_length_of(:code).is_at_most(32)}
  it { should validate_presence_of(:territory_id) }
  it { should validate_presence_of(:organisation_id) }
  it { should validate_presence_of(:parent) }
  it { should validate_presence_of(:owner_id) }
  it { should validate_presence_of(:created_by) }
  it { should validate_presence_of(:updated_by) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:group)).to be_valid
  end
  it 'is invalid without a code' do
    expect(build(:group, code: nil)).to_not be_valid
  end

end
