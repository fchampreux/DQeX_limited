# == Schema Information
#
# Table name: parameters
#
#  id                 :integer          not null, primary key
#  parameters_list_id :bigint
#  playground_id      :bigint
#  scope              :string(255)
#  name               :string(255)
#  code               :string(255)      not null
#  property           :string(255)      not null
#  description        :text
#  active_from        :datetime
#  active_to          :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Parameter < ApplicationRecord
extend CsvHelper

### validation
	validates :code, presence: true, uniqueness: {scope: :parameters_list_id, case_sensitive: false}, length: { maximum: 32 }
	validates :property, length: { maximum: 32 }
	# validates :description, presence: true, length: { maximum: 1000 }
	validates :active_from, presence: true
	validates :active_to, presence: true
	validates :parent,    presence: true
  belongs_to :parent, :class_name => "ParametersList", :foreign_key => "parameters_list_id"

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

end
