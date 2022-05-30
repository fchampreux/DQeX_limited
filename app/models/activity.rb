# == Schema Information
#
# Table name: activities
#
#  id                  :bigint           not null, primary key
#  playground_id       :bigint
#  business_process_id :bigint
#  organisation_id     :integer          default(0)
#  responsible_id      :integer          default(0)
#  deputy_id           :integer          default(0)
#  code                :string(255)      not null
#  name                :string(255)
#  description         :text
#  hierarchy           :string(255)      not null
#  status_id           :integer          default(0)
#  pcf_index           :string(255)
#  pcf_reference       :string(255)
#  is_finalised        :boolean          default(FALSE)
#  is_current          :boolean          default(TRUE)
#  is_active           :boolean          default(TRUE)
#  owner_id            :integer          not null
#  created_by          :string(255)      not null
#  updated_by          :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Activity < ApplicationRecord
# include ParametersHelper for testing node_type
extend CsvHelper
#acts_as_taggable
audited


### global identifier
   self.sequence_name = "global_seq"
   self.primary_key = "id"

### before filter
  before_create :set_hierarchy
  before_validation :set_code

	validates :code, presence: true, uniqueness: {scope: :business_process_id, case_sensitive: false}, length: { maximum: 32 }
	validates :created_by, presence: true
	validates :updated_by, presence: true
	validates :owner_id,   presence: true
	validates :status_id,  presence: true
	validates :playground_id, presence: true
	validates :pcf_index,      length: { maximum: 30 }
	validates :pcf_reference,  length: { maximum: 100 }
	validates :parent, presence: true
  validate :activity_compliance
  belongs_to :parent, :class_name => "BusinessProcess", :foreign_key => "business_process_id"
	belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
	belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :responsible, :class_name => "User", :foreign_key => "responsible_id"	# helps retrieving the user name
  belongs_to :deputy, :class_name => "User", :foreign_key => "deputy_id"	# helps retrieving the user name
  belongs_to :organisation, :class_name => "Organisation", :foreign_key => "organisation_id"	# helps retrieving the organisation name
  belongs_to :template, optional: true, class_name: "Activity", foreign_key: :template_id # References an activity used as a template
  belongs_to :technology, class_name: "Value", foreign_key: :technology_id
  belongs_to :gsbpm,  :class_name => "Value", :foreign_key => "gsbpm_id"	# helps retrieving the gsbpm process code
  belongs_to :source_object, class_name: "DeployedObject", foreign_key: :source_object_id
  belongs_to :target_object, class_name: "DeployedObject", foreign_key: :target_object_id
  belongs_to :success_next, class_name: "Activity", foreign_key: :success_next_id
  belongs_to :failure_next, class_name: "Activity", foreign_key: :failure_next_id
	belongs_to :node_type, :class_name => "Parameter", :foreign_key => "node_type_id"	# helps retrieving the status name
	has_many :tasks, as: :parent, dependent: :destroy
  accepts_nested_attributes_for :tasks, :reject_if => :all_blank, :allow_destroy => true

### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']
  has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true

### Public functions definitions

  def set_as_inactive(user)
    Activity.where("hierarchy = ?", self.hierarchy).each do |activity|
      activity.update_attributes(is_active: false, updated_by: user)
    end
  end

### private functions definitions
  private

  ### before filters

  def set_hierarchy
    if Activity.where("business_process_id = ?", self.business_process_id).count == 0
      self.hierarchy = self.parent.hierarchy + '.001'
    else
      last_one = Activity.where("business_process_id = ?", self.business_process_id).maximum("hierarchy")
      self.hierarchy = last_one.next
    end
  end

  def activity_compliance
    # Check that Start, End and Rescue activities are present, even when destroy is invoked
  end
end
