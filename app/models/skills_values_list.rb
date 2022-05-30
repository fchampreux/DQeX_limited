class SkillsValuesList < ApplicationRecord
audited

### Validations
  validates :playground_id, presence: true
  validates :skill_id, presence: true
  validates :values_list_id, presence: true

  # Custom validation of the filter attribute
  validate :values_filter

  belongs_to :type,
             class_name: 'Parameter',
             foreign_key: 'type_id',
             optional: true # helps retrieving the type name

  # Relations
  belongs_to :deployed_skill
  belongs_to :reference, class_name: "ValuesList", foreign_key: "values_list_id"
  belongs_to :values_list

  # translations management
  #has_many :translations, as: :document
  #has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  #accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true


  ### private functions definitions
    private

    def values_filter
      begin
        Value.where("#{filter}").first
      rescue
        self.errors.add(:filter, "is not correctly specified")
      end
    end
      
end
