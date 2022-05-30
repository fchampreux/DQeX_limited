# == Schema Information
#
# Table name: values
#
#  id             :integer          not null, primary key
#  values_list_id :bigint
#  code           :string(255)      not null
#  name           :string(255)
#  description    :text
#  level          :integer          default(1), not null
#  parent_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  playground_id  :bigint
#  alternate_code :string(255)
#  alias          :string(255)
#  abbreviation   :string(255)
#  anything       :json
#

require 'rails_helper'

RSpec.describe Value, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:value)}
    it { should respond_to(:code) }
    it { should validate_length_of(:code).is_at_most(32)}
    it { should validate_uniqueness_of(:code).scoped_to(:values_list_id).case_insensitive }
    it { should validate_presence_of(:parent) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:value)).to be_valid
  end
  it 'is invalid without a code' do
    expect(build(:value, code: nil)).to_not be_valid
  end


end
