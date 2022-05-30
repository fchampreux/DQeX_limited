class Annotation < ApplicationRecord
include AnnotationsHelper, TranslationsHelper, SessionsHelper
audited

### Before filter
  before_validation :set_code
  before_save :encrypt_password
  after_find :decrypt_password

	validates :code, presence: true, length: { maximum: 32 }
	validates :playground_id, presence: true
	#validates :parent, presence: true

  belongs_to :object_extra, polymorphic: true
  belongs_to :annotation_type, :class_name => "Parameter", :foreign_key => "annotation_type_id"	# helps retrieving the annotation type name

### Translation support
  mattr_accessor :translated_fields, default: ['description']
  has_many :translations, as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true

  def check_translations # create empty records for missing translations
    list_of_languages.order(:property).each do |locution|
      if not Translation.exists?(document_type: 'Annotation', document_id: self.id, field_name: 'description', language: locution.property)
        self.description_translations.build(field_name: 'description', language: locution.property, translation: nil)
      end
    end
  end

### private functions definitions
  private

  ### before filters
  def set_code
    if annotation_type_id == annotation_types.find { |x| x["code"] == "OTHER" }.id # Free input for code has to be formated
      self.code = code.gsub(/[^0-9A-Za-z]/, '-').upcase
    else
      self.code = Parameter.find(annotation_type_id).code # Set type as code
    end
    self.playground_id = self.object_extra.playground_id

    puts "######## Generated code ########"
    puts self.code
  end

  def encrypt_password
    if self.annotation_type_id == annotation_types.find { |x| x["code"] == "LOGIN" }.id and !self.uri.blank?
      key = Rails.application.credentials[:secret_key_base][0,32]
      crypt = ActiveSupport::MessageEncryptor.new(key)
      self.uri = crypt.encrypt_and_sign(self.uri)
    end
  end

  def decrypt_password
    if self.annotation_type_id == annotation_types.find { |x| x["code"] == "LOGIN" }.id and !self.uri.blank?
      key = Rails.application.credentials[:secret_key_base][0,32]
      crypt = ActiveSupport::MessageEncryptor.new(key)
      self.uri = crypt.decrypt_and_verify(self.uri)
    end
  end

end
