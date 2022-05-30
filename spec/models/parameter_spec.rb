# == Schema Information
#
# Table name: parameters
#
#  id                 :integer          not null, primary key
#  parameters_list_id :bigint
#  playground_id      :bigint
#  scope              :string(255)
#  name               :string(255)
#  code               :string(255)      not null
#  property           :string(255)      not null
#  description        :text
#  active_from        :datetime
#  active_to          :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe Parameter, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:parameter)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:code) }
    it { should validate_length_of(:property).is_at_most(32)}
    it { should validate_length_of(:code).is_at_most(32)}
    it { should validate_uniqueness_of(:code).scoped_to(:parameters_list_id).case_insensitive }
    it { should respond_to(:active_from) }
    it { should respond_to(:active_to) }


  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:parameter)).to be_valid
  end
  it 'is invalid without a name' do
    expect(build(:parameter, active_from: nil)).to_not be_valid
  end

end
