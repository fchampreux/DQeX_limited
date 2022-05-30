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

class DeployedSkill < Skill
  ### before filter
  before_validation :set_code

  # Custom validation of the filter attribute
  validate :values_filter
  validates :code, presence: true, uniqueness: {scope: :business_object_id, case_sensitive: false}, length: { maximum: 32 }

  belongs_to :template_skill, :class_name => "DefinedSkill", :foreign_key => "template_skill_id" # helps retrieving the skill template
  belongs_to :parent, :class_name => "DeployedObject", :foreign_key => "business_object_id"

  belongs_to :values_list, inverse_of: :deployed_skills
  belongs_to :classification, inverse_of: :deployed_skills

  has_many :skills_values_lists, foreign_key: "skill_id"
  has_many :references, class_name: "ValuesList", through: :skills_values_lists
  accepts_nested_attributes_for :skills_values_lists, :reject_if => :all_blank, :allow_destroy => true

  ### private functions definitions
    private

    ### format code
    def set_code
      if self.code[0, 3] == "DV_"
        self.code = self.code[3 .. -1]
      end
      self.code = "#{code.gsub(/[^0-9A-Za-z]/, '_')}".upcase[0,32]
    end

    def values_filter
      begin
        puts "----- Test the filter -----"
        Value.where("#{filter}").first
      rescue
        puts "----- Filter test failed -----"
        self.errors.add(:filter, "is not correctly specified")
        puts self.errors.map {|error, message| [error, message]}.join(', ')
      end
    end
end
