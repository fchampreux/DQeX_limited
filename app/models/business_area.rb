# == Schema Information
#
# Table name: business_areas
#
#  id             :bigint           not null, primary key
#  playground_id  :bigint
#  responsible_id :integer          default(0)
#  deputy_id      :integer          default(0)
#  code           :string(255)      not null
#  name           :string(255)
#  description    :text
#  hierarchy      :string(255)      not null
#  pcf_index      :string(255)
#  pcf_reference  :string(255)
#  status_id      :integer          default(0)
#  is_finalised   :boolean          default(TRUE)
#  is_current     :boolean          default(TRUE)
#  is_active      :boolean          default(TRUE)
#  owner_id       :integer          not null
#  created_by     :string(255)      not null
#  updated_by     :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reviewer_id    :integer
#

class BusinessArea < ApplicationRecord
extend CsvHelper
audited

### global identifier
   self.sequence_name = "global_seq"
   self.primary_key = "id"

### before filter
  before_create :set_hierarchy # Hierarchy is defined once at creation

### validations
  validates :code,        presence: true, uniqueness: {scope: :playground_id, case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
	#validates :organisation_id, presence: true
	validates :responsible_id, presence: true
	validates :deputy_id,      presence: true
	validates :pcf_index,     length: { maximum: 30 }
	validates :pcf_reference, length: { maximum: 100 }
  validates :parent,      presence: true
  belongs_to :parent, :class_name => "Playground", :foreign_key => "playground_id"
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :reviewer,  :class_name => "User", :foreign_key => "reviewer_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  ### OFS
	#belongs_to :organisation, :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation in charge
	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,  :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
  ### OFS

  has_many :data_policies, :inverse_of => :parent, :dependent => :destroy
	has_many :business_flows, :inverse_of => :parent, :dependent => :destroy
	has_many :defined_objects, as: :parent
	has_many :values_lists, :inverse_of => :parent, :dependent => :destroy
	has_many :classifications, :inverse_of => :parent, :dependent => :destroy

### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']
  has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true

### Public functions definitions

### private functions definitions
  private

  ### before filters
    def set_hierarchy
      if BusinessArea.where("playground_id = ?", self.playground_id).count == 0
        self.hierarchy = self.parent.hierarchy + '.001'
      else
        last_one = BusinessArea.where("playground_id = ?", self.playground_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end

end
