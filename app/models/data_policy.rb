# == Schema Information
#
# Table name: data_policies
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  business_area_id   :bigint
#  landscape_id       :bigint
#  territory_id       :bigint
#  organisation_id    :bigint
#  calendar_from_id   :bigint
#  calendar_to_id     :bigint
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  active_from        :datetime
#  active_to          :datetime
#  major_version      :integer          not null
#  minor_version      :integer          not null
#  new_version_remark :text
#  is_published       :boolean          default(TRUE)
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  status_id          :integer          default(0)
#  context_id         :integer          default(0)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class DataPolicy < ApplicationRecord
extend CsvHelper
audited

	### global identifier
	  self.sequence_name = "global_seq"
	  self.primary_key = "id"

	### before filter
	before_create :set_hierarchy

	### validations
  validates :code,        		presence: true, uniqueness: {scope: [:business_area_id, :major_version, :minor_version], case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , 		presence: true
  validates :updated_by,  		presence: true
  validates :owner_id,    		presence: true
  validates :status_id,   		presence: true
  validates :parent,      		presence: true
	validates :playground_id, 	presence: true
	validates :territory_id, 		presence: true
	validates :organisation_id, presence: true
	validates :active_from, presence: true
  belongs_to :parent, :class_name => "BusinessArea", :foreign_key => "business_area_id"
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
	belongs_to :territory # helps retrieving the territory name
	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,  :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
	belongs_to :organisation,  :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation in charge
	has_many :rules_for_processes
	has_many :business_rules, through: :rules_for_processes

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
	  # applies to all versions of the object
	  DataPolicy.where("hierarchy = ?", self.hierarchy).each do |policy|
	    policy.update_attributes(is_active: false, is_current: false, updated_by: user)
	  end
	end

	def full_version
	  # concatenates full version for easier output
	  self.major_version.to_s+'.'+self.minor_version.to_s
	end
	### private functions definitions
	  private

  ### before filters

    def set_hierarchy
      if DataPolicy.where("business_area_id = ?", self.business_area_id).count == 0
        self.hierarchy = self.parent.hierarchy + '*001'
      else
        last_one = DataPolicy.where("business_area_id = ?", self.business_area_id).maximum("hierarchy")
        self.hierarchy = last_one.next
      end
    end
end
