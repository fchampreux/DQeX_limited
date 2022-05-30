# == Schema Information
#
# Table name: business_objects
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  parent_type        :string
#  parent_id          :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  is_template        :boolean          default(TRUE)
#  template_object_id :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  status_id          :integer          default(0)
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_published       :boolean          default(TRUE)
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  reviewed_by        :integer
#  reviewed_at        :datetime
#  approved_by        :integer
#  approved_at        :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  period             :string(255)
#  ogd_id             :integer          default(0)
#  resource_file      :string(255)
#  granularity_id     :integer
#



require 'rails_helper'

RSpec.describe BusinessObject, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:business_object)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:code) }
    it { should validate_length_of(:code).is_at_most(32)}
    it { should validate_uniqueness_of(:code).scoped_to([:parent_type, :parent_id, :major_version, :minor_version]).case_insensitive }
    it { should validate_presence_of(:playground_id) }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:status_id) }
    it { should validate_presence_of(:organisation_id) }
    it { should validate_presence_of(:responsible_id) }
    it { should validate_presence_of(:deputy_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }
    it { should validate_presence_of(:major_version) }
    it { should validate_presence_of(:minor_version) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:business_object)).to be_valid
  end
  it 'is invalid without a status' do
    expect(build(:business_object, status_id: nil)).to_not be_valid
  end


end
