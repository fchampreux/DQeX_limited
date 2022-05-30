# == Schema Information
#
# Table name: values_lists
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  business_area_id   :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  ressource_name     :string(255)
#  hierarchy          :string(255)      not null
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  status_id          :integer          default(0)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  anything           :json
#  workflow_state     :string
#  type_id            :integer          default(0)
#

require 'rails_helper'

RSpec.describe ValuesList, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:values_list)}
    it { should validate_presence_of(:code) }
    it { should validate_length_of(:code).is_at_most(32)}
    it { should validate_uniqueness_of(:code).scoped_to([:business_area_id, :major_version, :minor_version]).case_insensitive }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }
    it { should validate_presence_of(:playground_id) }
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:status_id) }
    it { should validate_presence_of(:organisation_id) }
    it { should validate_presence_of(:responsible_id) }
    it { should validate_presence_of(:deputy_id) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:values_list)).to be_valid
  end
  it 'is invalid without a status' do
    expect(build(:values_list, status_id: nil)).to_not be_valid
  end

end
