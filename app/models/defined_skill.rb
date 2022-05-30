# == Schema Information
#
# Table name: skills
#
#  id                   :bigint           not null, primary key
#  playground_id        :bigint
#  business_object_id   :bigint
#  code                 :string(255)      not null
#  name                 :string(255)
#  description          :text
#  external_description :text
#  is_template          :boolean          default(TRUE)
#  template_skill_id    :integer          default(0)
#  skill_type_id        :integer          default(0)
#  skill_aggregation_id :integer          default(0)
#  skill_min_size       :integer          default(0)
#  skill_size           :integer
#  skill_precision      :integer
#  skill_unit_id        :integer          default(0)
#  skill_role_id        :integer          default(0)
#  is_mandatory         :boolean          default(FALSE)
#  is_array             :boolean          default(FALSE)
#  is_pk                :boolean          default(FALSE)
#  is_ak                :boolean          default(FALSE)
#  is_published         :boolean          default(TRUE)
#  is_multilingual      :boolean          default(FALSE)
#  sensitivity_id       :integer          default(0)
#  status_id            :integer          default(0)
#  owner_id             :integer          not null
#  is_finalised         :boolean          default(FALSE)
#  is_current           :boolean          default(TRUE)
#  is_active            :boolean          default(TRUE)
#  regex_pattern        :string(255)
#  min_value            :string(255)
#  max_value            :string(255)
#  created_by           :string(255)      not null
#  updated_by           :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  is_pairing_key       :boolean          default(FALSE)
#  source_type_id       :integer          default(0)
#  organisation_id      :integer          default(0)
#  responsible_id       :integer          default(0)
#  deputy_id            :integer          default(0)
#  workflow_state       :string
#  anything             :json
#

class DefinedSkill < Skill
### before filter
  before_validation :set_code

  #validates :code, presence: true, uniqueness: {scope: :playground_id, case_sensitive: false}, length: { maximum: 30 }
  validates :code, presence: true, uniqueness: {case_sensitive: false}, length: { maximum: 30 }

  has_many :deployed_skills, :inverse_of => :template_skill, :foreign_key => "template_skill_id"
  #belongs_to :parent, :class_name => "DefinedObject", :foreign_key => "business_object_id"

  belongs_to :values_list, inverse_of: :defined_skills
  belongs_to :classification, inverse_of: :defined_skills
end
