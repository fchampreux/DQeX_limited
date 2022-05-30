# == Schema Information
#
# Table name: tasks
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  parent_type        :string
#  parent_id          :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  pcf_index          :string(255)
#  pcf_reference      :string(255)
#  task_type_id       :integer          default(0)
#  script             :text
#  script_language_id :integer          default(0)
#  external_reference :string(255)
#  status_id          :integer          default(0)
#  owner_id           :integer          not null
#  is_finalised       :boolean          default(TRUE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe Task, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:task)}
    it { should validate_presence_of(:playground_id) }
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:code) }
    it { should validate_length_of(:code).is_at_most(32)}
    it { should validate_uniqueness_of(:code).scoped_to(:parent_type, :parent_id).case_insensitive }
		it { should validate_length_of(:pcf_index).is_at_most(30)}
		it { should validate_length_of(:pcf_reference).is_at_most(100)}
    it { should validate_presence_of(:owner_id) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:task)).to be_valid
  end
  it 'is invalid without a code' do
    expect(build(:task, code: nil)).to_not be_valid
  end


end
