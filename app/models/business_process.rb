# == Schema Information
#
# Table name: business_processes
#
#  id                   :bigint           not null, primary key
#  playground_id        :bigint
#  business_flow_id     :bigint
#  organisation_id      :integer          default(0)
#  responsible_id       :integer          default(0)
#  deputy_id            :integer          default(0)
#  code                 :string(255)      not null
#  name                 :string(255)
#  description          :text
#  hierarchy            :string(255)      not null
#  pcf_index            :string(255)
#  pcf_reference        :string(255)
#  status_id            :integer          default(0)
#  is_finalised         :boolean          default(TRUE)
#  is_current           :boolean          default(TRUE)
#  is_active            :boolean          default(TRUE)
#  owner_id             :integer          not null
#  created_by           :string(255)      not null
#  updated_by           :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_description :text
#

class BusinessProcess < ApplicationRecord
extend CsvHelper
audited

### global identifier
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### before filter
  before_validation :set_code
  before_create :set_hierarchy

### validations
  validates :code,        presence: true, uniqueness: {scope: :business_flow_id, case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
  validates :parent,      presence: true
	validates :playground_id, presence: true
  validates :pcf_index, length: { maximum: 30 }
  validates :pcf_reference, length: { maximum: 100 }
  belongs_to :parent, :class_name => "BusinessFlow", :foreign_key => "business_flow_id"
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :gsbpm,  :class_name => "Value", :foreign_key => "gsbpm_id"	# helps retrieving the gsbpm process code
  belongs_to :organisation	# helps retrieving the responsible organisation name
  belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
  belongs_to :deputy,       :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
  belongs_to :zone_from, :class_name => "Parameter", :foreign_key => "zone_from_id"	# helps retrieving the status name
  belongs_to :zone_to, :class_name => "Parameter", :foreign_key => "zone_to_id"	# helps retrieving the status name
  has_and_belongs_to_many :data_providers, :class_name => "Organisation", :join_table => "business_processes_organisations"
	has_many :deployed_objects, as: :parent
  has_many :production_jobs, :inverse_of => :parent, :dependent => :destroy
  has_many :business_rules, :through => :deployed_objects
	has_many :activities, :inverse_of => :parent, :dependent => :destroy
  has_many :production_jobs
  has_many :production_schedules, through: :production_jobs

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description', 'external_description']
  has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  has_many :external_description_translations, -> { where(field_name: 'external_description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :external_description_translations, :reject_if => :all_blank, :allow_destroy => true

### Public functions definitions

### private functions definitions
  private

  ### before filters
    def set_hierarchy
      if BusinessProcess.where("business_flow_id = ?", self.business_flow_id).count == 0
        self.hierarchy = self.parent.hierarchy + '.001'
      else
        last_one = BusinessProcess.where("business_flow_id = ?", self.business_flow_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end

end
