# == Schema Information
#
# Table name: business_rules
#
#  id                     :bigint           not null, primary key
#  playground_id          :bigint
#  business_object_id     :bigint
#  skill_id               :bigint
#  code                   :string(255)      not null
#  name                   :string(255)
#  description            :text
#  hierarchy              :string(255)      not null
#  active_from            :datetime
#  active_to              :datetime
#  major_version          :integer          not null
#  minor_version          :integer          not null
#  new_version_remark     :text
#  is_published           :boolean          default(TRUE)
#  is_finalised           :boolean          default(FALSE)
#  is_current             :boolean          default(TRUE)
#  is_active              :boolean          default(TRUE)
#  evaluation_contexts    :string(255)
#  default_aggregation_id :integer          default(0)
#  ordering_sequence      :string(255)
#  business_value         :text
#  check_description      :text
#  check_script           :text
#  check_error_message    :text
#  check_language_id      :integer          default(0)
#  correction_method      :text
#  correction_script      :text
#  correction_language_id :integer          default(0)
#  added_value            :float            default(0.0)
#  maintenance_cost       :float            default(0.0)
#  maintenance_duration   :float            default(0.0)
#  duration_unit_id       :integer          default(0)
#  rule_type_id           :integer          default(0)
#  rule_class_id          :integer          default(0)
#  severity_id            :integer          default(0)
#  complexity_id          :integer          default(0)
#  status_id              :integer          default(0)
#  owner_id               :integer          not null
#  created_by             :string(255)      not null
#  updated_by             :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organisation_id        :integer          default(0)
#  responsible_id         :integer          default(0)
#  deputy_id              :integer          default(0)
#  is_template            :integer          default(1)
#  template_object_id     :integer          default(0)
#

require 'rails_helper'

RSpec.describe BusinessRule, type: :model do

  describe 'Validations'
  subject {FactoryBot.build(:business_rule)}
    it { should validate_presence_of(:parent) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).scoped_to([:parent_type, :parent_id, :major_version, :minor_version]).case_insensitive }
    it { should validate_length_of(:code).is_at_most(32)}
    it { should validate_presence_of(:playground_id) }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:status_id) }
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:updated_by) }
    it { should validate_presence_of(:minor_version) }
    it { should validate_presence_of(:major_version) }

  describe 'It can be created'
  it 'has a valid factory' do
    expect(build(:business_rule)).to be_valid
  end
  it 'is invalid without a status' do
    expect(build(:business_rule, status_id: nil)).to_not be_valid
  end


=begin
###B.PROCESS5 to test that fields are checked for unicity
  describe "when business process is duplicated" do
    before do
      @business_process_duplicate = @business_process.dup
      @business_process_duplicate.save!
    end
    it {should_not be_valid}
  end
=end

end
