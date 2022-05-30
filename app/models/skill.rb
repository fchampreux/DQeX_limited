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

class Skill < ApplicationRecord
extend CsvHelper

# Manage finite state machine
include WorkflowActiverecord
workflow do
  state :new
    event :submit, :transitions_to => :submitted
  state :submitted
    event :accept, :transitions_to => :accepted
    event :reject, :transitions_to => :rejected
  state :accepted
    event :reopen, :transitions_to => :new
  state :rejected
    event :submit, :transitions_to => :submitted
end

# Trace modifications
audited

### global identifiers
  self.sequence_name = "global_seq"
  self.primary_key = "id"


  scope :defined, -> { where "is_template"  }
  scope :deployed, -> { where.not "is_template"  }

### before filter
  before_validation :set_code

### validation
  #validates :code, presence: true, uniqueness: {scope: :business_object_id, case_sensitive: false}, length: { maximum: 50 }
  validates :skill_type_id, presence: true
  validates :parent, presence: true
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  belongs_to :parent, :class_name => "BusinessObject", :foreign_key => "business_object_id"
  belongs_to :skill_type, :class_name => "Parameter", :foreign_key => "skill_type_id"	# helps retrieving the data type
  belongs_to :sensitivity, :class_name => "Parameter", :foreign_key => "sensitivity_id"	# helps retrieving the sensivity grade
  belongs_to :skill_role, :class_name => "Parameter", :foreign_key => "skill_role_id"	# helps retrieving the skill's role in an analysis
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :skill_unit, :class_name => "Parameter", :foreign_key => "skill_unit_id"	# helps retrieving the data type
  belongs_to :skill_aggregation, :class_name => "Parameter", :foreign_key => "skill_aggregation_id"	# helps retrieving the data type
	belongs_to :source_type,  :class_name => "Parameter", :foreign_key => "source_type_id"		# helps retrieving the type of source for this object
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"	# helps retrieving the user name
  belongs_to :responsible, :class_name => "User", :foreign_key => "responsible_id"	# helps retrieving the user name
  belongs_to :deputy, :class_name => "User", :foreign_key => "deputy_id"	# helps retrieving the user name
  belongs_to :organisation, :class_name => "Organisation", :foreign_key => "organisation_id"	# helps retrieving the organisation name
  #belongs_to :values_list
  #belongs_to :classification

  ### annotations
  has_many :annotations, as: :object_extra, :dependent => :destroy
  accepts_nested_attributes_for :annotations, :reject_if => :all_blank, :allow_destroy => true

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description', 'external_description'] # List of fields for which translations need to be managed
	has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  has_many :external_description_translations, -> { where(field_name: 'external_description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :external_description_translations, :reject_if => :all_blank, :allow_destroy => true

  ### public functions definitions

  def reference_type
    # Identify which type of values list is associated with the skill
    if self.values_list_id == nil
      'None'
    else
      'ValuesList'
    end
  end

  def has_hierarchical_values
    false
  end

  ### private functions definitions
  private

=begin
  ### format code
  def set_code
    if self.is_template
      self.code = code[0,32]
    else
      self.code = code.gsub(/[^0-9A-Za-z]/, '_').upcase
    end
  end
=end

end
