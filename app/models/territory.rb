# == Schema Information
#
# Table name: territories
#
#  id                 :integer          not null, primary key
#  playground_id      :bigint
#  territory_id       :bigint
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  territory_level    :integer          default(0)
#  hierarchy          :string(255)
#  status_id          :integer          default(0)
#  parent_id          :integer
#  external_reference :string(255)
#  is_finalised       :boolean          default(FALSE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  owner_id           :integer          not null
#  created_by         :string(255)      not null
#  updated_by         :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Territory < ApplicationRecord
extend CsvHelper
audited


# This virtual attribute allows user to ignore parent value id
attr_accessor :parent_code

### before filter
  before_save :set_parent_id # user only inputs parent code when building a hierarchy
  # before_create :set_hierarchy
  # before_validation :set_code

  ### validations
  validates :code,        presence: true, uniqueness: {case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true

  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :ancestor, :class_name => "Territory", :foreign_key => "territory_id"
  has_many :child_territories, :class_name => "Territory" , :foreign_key => "territory_id"	# link to the child territories
  has_many :data_policies

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']
	has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true

### private functions definitions
  private

### before filters
    def set_code
      if territory_level > 1		#Undefined territory exists, but is a parent for none
        self.code = self.parent.code + '-' + code
        self.territory_level = self.parent.territory_level + 1
      end
    end

    def set_parent_id
      # Identify the parent
  		self.territory_level = 1
      if not self.parent_code.blank?
  			puts "Search for parent"
  			@parent = Territory.where("code = ? ", self.parent_code).first
        if @parent
  			  self.territory_id = @parent.id # To remove for harmonisation of hierarchical lists
    			self.parent_id = @parent.id
  			  self.territory_level = @parent.territory_level.next
        else
  			  self.territory_id = nil # To remove for harmonisation of hierarchical lists
    			self.parent_id = nil
  			  self.territory_level = 1
        end
  		end
    end

=begin
    def set_hierarchy
      if Territory.where("playground_id = ?", self.playground_id).count == 0
        self.hierarchy = self.playground.hierarchy + '.001'
      else
        if Territory.where("territory_id = ?", self.territory_id).count == 0
          self.hierarchy = self.parent.hierarchy + '.001'
        else
          last_one = Territory.where("territory_id = ?", self.territory_id).maximum("hierarchy")
          self.hierarchy = last_one.next
        end
      end
    end
=end

end
