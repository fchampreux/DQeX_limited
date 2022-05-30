# == Schema Information
#
# Table name: mappings
#
#  id               :integer          not null, primary key
#  mappings_list_id :bigint
#  source_value_id  :integer
#  target_value_id  :integer
#  is_active        :boolean          default(TRUE)
#  active_from      :datetime
#

require 'rails_helper'

RSpec.describe Mapping, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:mapping)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:source_software) }
    it { should validate_presence_of(:source_table) }
    it { should validate_presence_of(:source_code) }
    it { should validate_presence_of(:source_property) }
    it { should validate_presence_of(:target_software) }
    it { should validate_presence_of(:target_table) }
    it { should validate_presence_of(:target_code) }
    it { should validate_presence_of(:target_property) }
		it { should validate_length_of(:source_software).is_at_most(100)}
		it { should validate_length_of(:source_table).is_at_most(100)}
		it { should validate_length_of(:source_code).is_at_most(100)}
		it { should validate_length_of(:source_property).is_at_most(100)}
		it { should validate_length_of(:target_software).is_at_most(100)}
		it { should validate_length_of(:target_table).is_at_most(100)}
		it { should validate_length_of(:target_code).is_at_most(100)}
		it { should validate_length_of(:target_property).is_at_most(100)}

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:mapping)).to be_valid
  end
  it 'is invalid without a source' do
    expect(build(:mapping, source_table: nil)).to_not be_valid
  end

end
