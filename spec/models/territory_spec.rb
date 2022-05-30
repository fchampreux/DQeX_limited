# == Schema Information
#
# Table name: territories
#
#  id                 :integer          not null, primary key
#  playground_id      :bigint
#  territory_id       :bigint
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  territory_level    :integer          default(0)
#  hierarchy          :string(255)
#  status_id          :integer          default(0)
#  parent_id          :integer
#  external_reference :string(255)
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe Territory, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:territory)}
    it { should validate_presence_of(:code) }
    it { should validate_length_of(:code).is_at_most(32)}
    it { should validate_uniqueness_of(:code).scoped_to(:playground_id).case_insensitive }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:territory)).to be_valid
  end
  it 'is invalid without a code' do
    expect(build(:territory, code: nil)).to_not be_valid
  end
=begin
###PARAM5 to test that fields are checked for unicity
  describe "when parameter is duplicated" do
    before do
      @parameter_duplicate = @parameter.dup
      @parameter_duplicate.save!
    end
    it {should_not be_valid}
  end
=end

end
