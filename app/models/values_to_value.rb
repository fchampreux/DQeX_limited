# == Schema Information
#
# Table name: values_to_values
#
#  id                    :integer          not null, primary key
#  playground_id         :bigint
#  classification_id          :bigint
#  parent_values_list_id :bigint
#  child_values_list_id  :bigint
#  parent_value_id       :bigint
#  child_value_id        :bigint
#  code                  :string(255)      not null
#  name                  :string(255)      not null
#  description           :text             not null
#  sort_order            :integer          default(0)
#  type_id               :integer          default(0)
#  anything              :json
#

class ValuesToValue < ApplicationRecord
audited

### Validations
  validates :code,        presence: true, uniqueness: {scope: :classification_id, case_sensitive: false}, length: { maximum: 32 }
  belongs_to :type, :class_name => "Parameter", :foreign_key => "type_id"	# helps retrieving the type name
  belongs_to :values_list
  belongs_to :child_values_list,  :class_name => "ValuesList", :foreign_key => "child_values_list_id"

  # Relations
  belongs_to :value
  belongs_to :child_value,  :class_name => "Value", :foreign_key => "child_value_id"

  # translations management
  has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
end
