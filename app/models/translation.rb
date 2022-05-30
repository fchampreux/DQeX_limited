# == Schema Information
#
# Table name: translations
#
#  id            :integer          not null, primary key
#  document_type :string
#  document_id   :bigint
#  field_name    :string(255)      not null
#  language      :string(255)      not null
#  translation   :text
#  searchable    :tsvector
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Translation < ApplicationRecord
# extend CsvHelper
### full-text search
  include PgSearch::Model
  pg_search_scope :search_by_translation, against: :translation

### scope
  scope :current_language, ->(current_language) { where "language=?", current_language }
	scope :other_languages, ->(current_language) { where "language!=?", current_language }
  scope :field, ->(field) {where "field_name=?", field}
  scope :no_leaves, ->{ where.not(document_type: ['Value','Skill','Task'])}

### before filter : none

### validation
	validates :field_name, presence: true
  validates :language, presence: true
  validates_uniqueness_of :language, :scope => [:document_type, :document_id, :field_name]
  belongs_to :document, polymorphic: true

  ### private functions definitions
  private

end
