class ValuesListsClassification < ApplicationRecord
audited

### Validations
  validates :level,
            presence: true,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than: 10 }
  belongs_to :type,
             class_name: 'Parameter',
             foreign_key: 'type_id',
             optional: true # helps retrieving the type name

  # Relations
  belongs_to :classification
  belongs_to :values_list

  # translations management
  has_many :translations, as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
end
