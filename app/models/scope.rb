# == Schema Information
#
# Table name: scopes
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  business_object_id :bigint
#  landscape_id       :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  status_id          :integer          default(0)
#  hierarchy          :string(255)      not null
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  load_interface     :string(255)
#  connection_string  :string(255)
#  structure_name     :string(255)
#  query              :text
#  resource_file      :string(255)
#  is_validated       :boolean          default(FALSE)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Scope < ApplicationRecord
extend CsvHelper
audited

#################################################################
### The scope describes how a business object is instanciated ###
### wether in a table, a file, or another resource            ###
#################################################################

### global identifier
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### before filter
  before_create :set_hierarchy

### translated attributes used as temporary variables for new and edit actions
  attr_accessor :uploaded_file

### validations
	validates :code,          presence: true, uniqueness: {scope: [:business_object_id, :major_version, :minor_version], case_sensitive: false}, length: { maximum: 32 }
	validates :created_by ,   presence: true
	validates :updated_by,    presence: true
	validates :owner_id,      presence: true
	validates :status_id,     presence: true
	validates :playground_id, presence: true
  validates :parent,        presence: true
	belongs_to :owner,  :class_name => "User",      :foreign_key => "owner_id"		# helps retrieving the owner name
	belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
	belongs_to :parent, :class_name => "Landscape", :foreign_key => "landscape_id"		# helps retrieving the owner name
	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,  :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
	belongs_to :organisation,  :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation in charge

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
    Scope.where("hierarchy = ?", self.hierarchy).maximum("major_version")
  end

  def last_minor_version
    Scope.where("hierarchy = ?", self.hierarchy).maximum("minor_version")
  end

  def set_as_current(user)
    Scope.where("hierarchy = ?", self.hierarchy).each do |scope|
      # clears the is_current flag for duplicated version
      scope.update_attributes(is_current: false)
    end
    # sets the is_current flag for duplicated version
    self.update_attributes(is_current: true, updated_by: user)
  end

  def set_as_finalised(user)
    # sets the is_finalised flag
    self.update_attributes(is_finalised: true, updated_by: user)
  end

  def set_as_inactive(user)
    Scope.where("hierarchy = ?", self.hierarchy).each do |scope|
      scope.update_attributes(is_active: false, updated_by: user)
    end
  end

### private functions definitions
  private

  ### before filters

    def set_hierarchy
      if Scope.where("business_object_id = ?", self.business_object_id).count == 0
        self.hierarchy = self.parent.hierarchy + '/001'
      else
        last_one = Scope.where("business_object_id = ?", self.business_object_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end

end
