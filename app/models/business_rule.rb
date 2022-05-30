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

class BusinessRule < ApplicationRecord

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

#acts_as_taggable
audited

### global identifier
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### scope
  scope :bp, ->(bp_id) { where("business_object_id=?", bp_id) if bp_id.present?}

### before filter
  before_create :set_hierarchy

### validations
  validates :code,        presence: true, uniqueness: {scope: [:parent, :major_version, :minor_version], case_sensitive: false}, length: { maximum: 32 }
  validates :created_by,  presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
  validates :status_id,   presence: true
  validates :minor_version,      presence: true
  validates :major_version,      presence: true
  validates :playground_id, presence: true
  belongs_to :parent, :class_name => "DeployedObject", :foreign_key => "business_object_id"
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
	belongs_to :rule_type, :class_name => "Parameter", :foreign_key => "rule_type_id"	# helps retrieving the rule type name
	belongs_to :rule_class, :class_name => "Parameter", :foreign_key => "rule_class_id"	# helps retrieving the rule class name
	belongs_to :severity, :class_name => "Parameter", :foreign_key => "severity_id"		# helps retrieving the severity grade
	belongs_to :complexity, :class_name => "Parameter", :foreign_key => "complexity_id"	# helps retrieving the complexity grade
	belongs_to :check_language, :class_name => "Parameter", :foreign_key => "check_language_id"	# helps retrieving the check script language
	belongs_to :correction_language, :class_name => "Parameter", :foreign_key => "correction_language_id"	# helps retrieving the correction script language
  belongs_to :skill, :class_name => 'DeployedSkill', foreign_key: "skill_id"					# helps retrieving the target business object skill name
	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,  :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
	belongs_to :organisation,  :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation in charge

	has_many :rules_for_processes
	has_many :data_policies, through: :rules_for_processes
  has_many :business_processes, through: :rules_for_processes
  has_many :breaches
  has_many :tasks, as: :parent
  accepts_nested_attributes_for :tasks, :reject_if => :all_blank, :allow_destroy => true

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description', 'business_value', 'check_description', 'correction_method', 'check_error']
  has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  has_many :business_value_translations, -> { where(field_name: 'business_value') }, class_name: 'Translation', as: :document
  has_many :check_description_translations, -> { where(field_name: 'check_description') }, class_name: 'Translation', as: :document
  has_many :correction_method_translations, -> { where(field_name: 'correction_method') }, class_name: 'Translation', as: :document
  has_many :check_error_message_translations, -> { where(field_name: 'check_error_message') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :business_value_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :check_description_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :correction_method_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :check_error_message_translations, :reject_if => :all_blank, :allow_destroy => true

### Public functions definitions

def full_version
  # concatenates full version for easier output
  self.major_version.to_s+'.'+self.minor_version.to_s
end

def last_version
  BusinessRule.where("hierarchy = ?", self.hierarchy).maximum("major_version")
end

# Should pass the related major version to be relevant
def last_minor_version
  BusinessRule.where("hierarchy = ? and major_version = ?", self.hierarchy, self.major_version).maximum("minor_version")
end

def set_as_current(user)
  BusinessRule.where("hierarchy = ?", self.hierarchy).each do |rule|
    # clears the is_current flag for duplicated version
    rule.update_attributes(is_current: false)
  end
  # sets the is_current flag for duplicated version
  self.update_attributes(is_current: true, updated_by: user)
end

def set_as_finalised(user)
  # sets the is_finalised flag
  self.update_attributes(is_finalised: true, updated_by: user)
end

def set_as_inactive(user)
  # applies to all versions of the object
  BusinessRule.where("hierarchy = ?", self.hierarchy).each do |rule|
    rule.update_attributes(is_active: false, is_current: false, updated_by: user)
  end
end

def bp_index(id)
  @business_rules = BusinessRule.joins(translated_rules).pgnd(current_playground).bp(params[:id]).visible.
    select(index_fields).order(order_by)
end

### private functions definitions
  private

  ### before filters

    def set_hierarchy
      if BusinessRule.where("business_object_id = ?", self.business_object_id).count == 0
        self.hierarchy = (self.parent&.hierarchy || '01.001-001') + '*001'
      else
        last_one = BusinessRule.where("business_object_id = ?", self.business_object_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end

  ### queries tayloring --> should be in a Concern ! Test to move to Model layer, æctually not used at the moment
=begin
    def names
      Translation.arel_table.alias('tr_names')
    end

    def descriptions
      Translation.arel_table.alias('tr_descriptions')
    end

    def rules
      BusinessRule.arel_table
    end

    def translated_rules
      rules.
      join(names, Arel::Nodes::OuterJoin).on(rules[:id].eq(names[:document_id]).and(names[:document_type].eq("BusinessRule")).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
      join(descriptions, Arel::Nodes::OuterJoin).on(rules[:id].eq(descriptions[:document_id]).and(descriptions[:document_type].eq("BusinessRule")).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
      join_sources
    end

    def index_fields
      [rules[:id], rules[:code], rules[:hierarchy], rules[:name], rules[:description], rules[:major_version], rules[:minor_version], rules[:status_id], rules[:updated_by], rules[:updated_at], rules[:is_active], rules[:is_current], rules[:is_finalised],
       names[:translation].as("translated_name"),
       descriptions[:translation].as("translated_description")]
    end

    def order_by
      [rules[:hierarchy].asc,rules[:major_version], rules[:minor_version]]
    end
=end
end
