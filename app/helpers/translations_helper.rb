module TranslationsHelper
include SessionsHelper

# list languages available for translations based on languages listed in Parameters

  # retrieve the list of available languages
  def list_of_languages
    list_id = ParametersList.where("code=?", 'LIST_OF_LANGUAGES').take!
    Parameter.joins(:name_translations).where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
              .where("translations.language = ?", current_language)
              .select("parameters.id, parameters.code, parameters.property, translations.translation as name" )
  end

  def check_translations(this_object)
    # Add missing translations for each configured language
    languages_set = list_of_languages.map {|p| p.property}
    targeted_translations = this_object.translated_fields.product languages_set
    existing_translations = this_object.translations.map {|f| [f.field_name, f.language]}
    translations_to_add = targeted_translations - existing_translations
    translations_to_add.each do |locution|
      this_object.translations.create(field_name: locution[0], language: locution[1])
    end
  end

  # Return translation for current language
  def translation_for(translation)
    if translation.exists?(language: current_language)
      return translation.where('language = ?', current_language).first.translation
    elsif translation.exists?(language: 'en')
      return translation.where('language = ?', 'en').first.translation
    else
      return t('MissingTranslation')
    end
  end

  
=begin
  def translatable
    Translation.arel_table
  end

  def existing_translations(document_type, document_id, field_name)
    translatable.where(translatable[:document_type].eq(document_type).and(translatable[:document_id].eq(document_id)).and(translatable[:field_name].eq(field_name)))
  end

  def parameterable
    Parameter.arel_table
  end

  def available_languages
    parameterable.where(parameterable[:parameters_list_id].eq(3))
  end

  def available_translations
    existing_translations(document_type, document_id, field_name).join(available_languages, Arel::Nodes::OuterJoin.on(translatable[:language].eq(available_languages[:property]))
  end

  def index_fields(document_type, document_id, field_name)
    [document_type.as("document_type"), document_id.as("document_id"), field_name.as("field_name"), available_languages[:property].as("language"),
  ]
  end
=end
end
