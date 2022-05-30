# == Schema Information
#
# Table name: classifications
#
#  id                 :bigint           not null
#  playground_id      :bigint
#  business_area_id   :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  type_id            :integer          default(0)
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
#  workflow_state     :string
#  anything           :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Classification < ApplicationRecord
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

### scope
  #scope :visible, -> { where "is_active and (is_current or is_finalised)" }
  scope :finalised, -> { where "is_active and is_finalised" }

### before filter
  before_create :set_hierarchy
  before_validation :set_code

### Validations
  validates :code,        presence: true, uniqueness: {scope: [:business_area_id, :major_version, :minor_version], case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
  validates :parent,      presence: true
  belongs_to :parent, :class_name => "BusinessArea", :foreign_key => "business_area_id"
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :responsible, :class_name => "User", :foreign_key => "responsible_id"	# helps retrieving the user name
  belongs_to :deputy, :class_name => "User", :foreign_key => "deputy_id"	# helps retrieving the user name
  belongs_to :organisation, :class_name => "Organisation", :foreign_key => "organisation_id"	# helps retrieving the organisation name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :type, :class_name => "Parameter", :foreign_key => "type_id"	# helps retrieving the type name

  # Relations
  has_many :deployed_skills
  has_many :defined_skills
  has_many :values_lists_classifications
  has_many :values_lists, through: :values_lists_classifications
  accepts_nested_attributes_for :values_lists_classifications, :reject_if => :all_blank, :allow_destroy => true

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
  Classification.where("hierarchy = ?", self.hierarchy).maximum("major_version")
end

# Should pass the related major version to be relevant
def last_minor_version
  Classification.where("hierarchy = ? and major_version = ?", self.hierarchy, self.major_version).maximum("minor_version")
end

def set_as_current(user)
  Classification.where("hierarchy = ?", self.hierarchy).each do |classification|
    # clears the is_current flag for duplicated version
    classification.update_attributes(is_current: false)
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
  Classification.where("hierarchy = ?", self.hierarchy).each do |classification|
    classification.update_attributes(is_active: false, is_current: false, updated_by: user)
  end
end

### private functions definitions
  private

  ### before filters

    def set_hierarchy
      if Classification.where("business_area_id = ?", self.business_area_id).count == 0
        self.hierarchy = self.parent.hierarchy + '*001'
      else
        last_one = Classification.pgnd(self.playground_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end



end
