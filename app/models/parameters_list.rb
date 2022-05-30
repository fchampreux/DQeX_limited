# == Schema Information
#
# Table name: parameters_lists
#
#  id            :integer          not null, primary key
#  playground_id :bigint
#  code          :string(255)      not null
#  name          :string(255)
#  description   :text
#  is_active     :boolean          default(TRUE)
#  status_id     :integer          default(0)
#  owner_id      :integer          not null
#  created_by    :string(255)      not null
#  updated_by    :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ParametersList < ApplicationRecord
extend CsvHelper
audited

### scope
# Parameters are global to the project

### before filter
  before_validation :set_code

### translated attributes used as temporary variables for new and edit actions
#  attr_accessor :tr_name, :tr_description

### global identifier
    self.sequence_name = "global_seq"
    self.primary_key = "id"

### validation
  validates :code, presence: true, uniqueness: {case_sensitive: false} , length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :owner_id,    presence: true
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  has_many :parameters, :inverse_of => :parent, :dependent => :destroy
  accepts_nested_attributes_for :parameters, :reject_if => :all_blank, :allow_destroy => true

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
   def set_code
     self.code = name.gsub(/[^0-9A-Za-z]/, '_').upcase ### The code is used to query the list of parameters
   end
end
