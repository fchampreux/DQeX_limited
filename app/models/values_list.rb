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
#  resource_name     :string(255)
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

class ValuesList < ApplicationRecord
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

audited

### global identifier
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### Scopes
  #scope :masterdata, -> { where.not(type_id: (values_list_types.find { |x| x["code"] == 'INFRASTRUCTURE' }).id) }
  #scope :attribut, -> { where.not("type = ? or type = ?", (values_list_types.find { |x| x["code"] == 'INFRASTRUCTURE' }).id, (values_list_types.find { |x| x["code"] == 'MASTERDATA' }).id) }
  #scope :infrastructure, -> { where(type_id: (values_list_types.find { |x| x["code"] == 'INFRASTRUCTURE' }).id) }

### before filter
  before_create :set_hierarchy
  before_validation :set_code
  #before_save   :set_max_level

### validation
  validates :code,        presence: true, uniqueness: {scope: [:business_area_id, :major_version, :minor_version], case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
  validates :status_id,   presence: true
	validates :organisation_id, presence: true
	validates :responsible_id,  presence: true
	validates :deputy_id,       presence: true
  validates :playground_id,   presence: true
  validates :parent,      presence: true
  belongs_to :parent, :class_name => "BusinessArea", :foreign_key => "business_area_id"
  belongs_to :code_type,  :class_name => "Parameter", :foreign_key => "code_type_id"		# helps retrieving the owner name
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :list_type, :class_name => "Parameter", :foreign_key => "list_type_id"	# helps retrieving the list type name
  belongs_to :code_type,  :class_name => "Parameter", :foreign_key => "code_type_id"		# helps retrieving the list code data type
  ### OFS
	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,       :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
	belongs_to :organisation, :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation name
  ### OFS

  # Relations
  has_many :deployed_skills
  has_many :defined_skills
  has_many :values_lists_classifications
  has_many :classifications, through: :values_lists_classifications
  has_many :values, :inverse_of => :parent, :dependent => :delete_all
  accepts_nested_attributes_for :values, :reject_if => :all_blank, :allow_destroy => true

  has_many :skills_values_lists, :foreign_key => "values_list_id"
  has_many :referents, class_name: "DeployedSkill", through: :skills_values_lists

  ### annotations
  has_many :annotations, as: :object_extra, :dependent => :destroy
  accepts_nested_attributes_for :annotations, :reject_if => :all_blank, :allow_destroy => true

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']
  has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true

  ### Public functions definitions

  def full_version
    # concatenates full version for easier output
    self.major_version.to_s+'.'+self.minor_version.to_s
  end

  def last_version
    ValuesList.where("hierarchy = ?", self.hierarchy).maximum("major_version")
  end

# Should pass the related major version to be relevant
  def last_minor_version
    ValuesList.where("hierarchy = ? and major_version = ?", self.hierarchy, self.major_version).maximum("minor_version")
  end

  def set_as_current(user)
    ValuesList.where("hierarchy = ?", self.hierarchy).each do |list|
      # clears the is_current flag for duplicated version
      list.update_attributes(is_current: false)
    end
    # sets the is_current flag for duplicated version
    self.update_attributes(is_current: true, updated_by: user)
  end

  def set_as_finalised(user)
    # sets the is_finalised flag
    self.update_attributes(is_finalised: true, updated_by: user)
  end

  def set_as_inactive(user)
    # applies to all versions of the list
    ValuesList.where("hierarchy = ?", self.hierarchy).each do |list|
      list.update_attributes(is_active: false, updated_by: user)
    end
  end

  def is_hierarchical
    if self.values.count <= 1 # First value cannot be assigned a parent of the hierarchy
      return false
    else
      return self.values.maximum(:level) > 1
    end
  end

  def set_max_level
    self.max_levels = self.values.maximum(:level) || 0
    self.is_hierarchical = self.max_levels <= 1 ? false : true
  end

### private functions definitions
  private

  ### before filters

    def set_hierarchy
      if ValuesList.where("business_area_id = ?", self.business_area_id).count == 0
        self.hierarchy = self.parent.hierarchy + '*001'
      else
        last_one = ValuesList.pgnd(self.playground_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end

end
