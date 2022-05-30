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

class BusinessObject < ApplicationRecord
extend CsvHelper
#acts_as_taggable
audited

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

### global identifier
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### before filter
  before_validation :set_code
  before_create :set_hierarchy

  ### validations
  validates :code,        presence: true, uniqueness: {scope: [:parent_type, :parent_id, :major_version, :minor_version], case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
  validates :status_id,   presence: true
	validates :organisation_id, presence: true
	validates :responsible_id, presence: true
	validates :deputy_id,      presence: true
  validates :parent,      presence: true
	validates :playground_id, presence: true
	validates :major_version, presence: true
	validates :minor_version, presence: true
  belongs_to :parent, polymorphic: true
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :type,   :class_name => "Parameter", :foreign_key => "type_id"	# helps retrieving the type of business object
	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,  :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
	belongs_to :organisation,  :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation in charge
  ### OFS
  belongs_to :granularity, :class_name => "Parameter", :foreign_key => "granularity_id"	# helps retrieving the regionality
  belongs_to :ogd, :class_name => "Parameter", :foreign_key => "ogd_id"	# helps retrieving the collect method
  belongs_to :connection, :class_name => "Value", :foreign_key => "connection_id"	# helps retrieving the hosting server connection
  has_and_belongs_to_many :participants, :class_name => "Organisation", :join_table => "business_objects_organisations"
  ### OFS
  has_many :business_rules, :inverse_of => :parent, :dependent => :destroy
  has_many :scopes, :inverse_of => :parent, :dependent => :destroy

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
    BusinessObject.where("hierarchy = ?", self.hierarchy).maximum("major_version")
  end

# Should pass the related major version to be relevant
  def last_minor_version
    BusinessObject.where("hierarchy = ? and major_version = ?", self.hierarchy, self.major_version).maximum("minor_version")
  end

  def set_as_current(user)
    BusinessObject.where("hierarchy = ?", self.hierarchy).each do |object|
      # clears the is_current flag for duplicated version
      object.update_attributes(is_current: false)
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
    BusinessObject.where("hierarchy = ?", self.hierarchy).each do |object|
      object.update_attributes(is_active: false, updated_by: user)
    end
  end

### private functions definitions
  private

  ### before filters
  ### calculate hierarchy considering polymorphism
    def set_hierarchy
      if BusinessObject.where("parent_id = ? and parent_type = ?", self.parent_id, self.parent_type).count == 0
        self.hierarchy = self.parent.hierarchy + '-001'
      else
        last_one = BusinessObject.where("parent_id = ? and parent_type = ?", self.parent_id, self.parent_type).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end

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
