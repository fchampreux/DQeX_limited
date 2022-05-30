# == Schema Information
#
# Table name: parameters_lists
#
#  id            :integer          not null, primary key
#  playground_id :bigint
#  code          :string(255)      not null
#  name          :string(255)
#  description   :text
#  is_active     :boolean          default(TRUE)
#  status_id     :integer          default(0)
#  owner_id      :integer          not null
#  created_by    :string(255)      not null
#  updated_by    :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe ParametersList, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:parameters_list)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:parameters_list)).to be_valid
  end
  it 'is invalid without calculated code' do
    expect(build(:parameters_list, name: '')).to_not be_valid
  end
  it 'has valid code calculation' do
    expect(build(:parameters_list, name: "@1+ b")).to be_valid
  end

end
