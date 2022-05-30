# == Schema Information
#
# Table name: business_flows
#
#  id               :bigint           not null, primary key
#  playground_id    :bigint
#  business_area_id :bigint
#  organisation_id  :integer          default(0)
#  responsible_id   :integer          default(0)
#  deputy_id        :integer          default(0)
#  code             :string(255)      not null
#  name             :string(255)
#  description      :text
#  hierarchy        :string(255)      not null
#  pcf_index        :string(255)
#  pcf_reference    :string(255)
#  status_id        :integer          default(0)
#  is_finalised     :boolean          default(TRUE)
#  is_current       :boolean          default(TRUE)
#  is_active        :boolean          default(TRUE)
#  owner_id         :integer          not null
#  created_by       :string(255)      not null
#  updated_by       :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active_from      :datetime         default(Thu, 14 May 2020 10:49:30 UTC +00:00)
#  active_to        :datetime         default(Thu, 14 May 2020 10:49:30 UTC +00:00)
#  legal_basis      :text
#  collect_type_id  :integer          default(0)
#

class BusinessFlow < ApplicationRecord
extend CsvHelper
audited

### global identifier
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### before filter
  before_create :set_hierarchy

### validations
  validates :code,        presence: true, uniqueness: {scope: :business_area_id, case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
	validates :organisation_id, presence: true
	validates :responsible_id, presence: true
	validates :deputy_id,      presence: true
# validates :status_id,   presence: true
  validates :parent,      presence: true
	validates :playground_id, presence: true
  validates :pcf_index, length: { maximum: 30 }
  validates :pcf_reference, length: { maximum: 100 }
  belongs_to :parent, :class_name => "BusinessArea", :foreign_key => "business_area_id"
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  ### OFS
	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,       :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
	belongs_to :organisation, :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation in charge
  belongs_to :collect_type, :class_name => "Parameter", :foreign_key => "collect_type_id"	# helps retrieving the collect method
  has_and_belongs_to_many :participants, :class_name => "Organisation", :join_table => "business_flows_organisations"
  ### OFS
  has_many :business_processes, :inverse_of => :parent, :dependent => :destroy
  has_many :deployed_objects, through: :business_processes

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description', 'legal_basis']
  has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  has_many :legal_basis_translations, -> { where(field_name: 'legal_basis') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :legal_basis_translations, :reject_if => :all_blank, :allow_destroy => true

  ### Public functions definitions

### private functions definitions
  private

  ### before filters
    def set_hierarchy
      if BusinessFlow.where("business_area_id = ?", self.business_area_id).count == 0
        self.hierarchy = self.parent.hierarchy + '.001'
      else
        last_one = BusinessFlow.where("business_area_id = ?", self.business_area_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end

end
