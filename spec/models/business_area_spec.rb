# == Schema Information
#
# Table name: business_areas
#
#  id             :bigint           not null, primary key
#  playground_id  :bigint
#  responsible_id :integer          default(0)
#  deputy_id      :integer          default(0)
#  code           :string(255)      not null
#  name           :string(255)
#  description    :text
#  hierarchy      :string(255)      not null
#  pcf_index      :string(255)
#  pcf_reference  :string(255)
#  status_id      :integer          default(0)
#  is_finalised   :boolean          default(TRUE)
#  is_current     :boolean          default(TRUE)
#  is_active      :boolean          default(TRUE)
#  owner_id       :integer          not null
#  created_by     :string(255)      not null
#  updated_by     :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reviewer_id    :integer
#

require 'rails_helper'

RSpec.describe BusinessArea, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:business_area)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).scoped_to(:playground_id).case_insensitive }
    it { should validate_length_of(:code).is_at_most(32)}
		it { should validate_length_of(:pcf_index).is_at_most(30)}
		it { should validate_length_of(:pcf_reference).is_at_most(100)}
    it { should validate_presence_of(:owner_id) }
  #  it { should validate_presence_of(:organisation_id) }
    it { should validate_presence_of(:responsible_id) }
    it { should validate_presence_of(:deputy_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:business_area)).to be_valid
  end
  it 'is invalid without a code' do
    expect(build(:business_area, code: nil)).to_not be_valid
  end

###B.AREA5 to test that fields are checked for unicity
#  describe "when business Area is duplicated" do
#    before do
#      @business_area_duplicate = @business_area.dup
#      @business_area_duplicate.save!
#    end
#    it {should_not be_valid}
#  end
end
