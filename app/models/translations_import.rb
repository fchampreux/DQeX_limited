class TranslationsImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include TranslationsHelper

  attr_accessor :file, :language, :playground

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    puts '########## translations ##############'
    if imported_translations.map(&:valid?).all?
      imported_translations.each(&:save!)
      true
    else
      imported_translations.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_translations
    @imported_translations ||= load_imported_translations
  end

  def load_imported_translations

    # Target container
    updated_translations = Array.new

    # List the fields in translation job
    list_of_fields = ['name', 'description']

    # Initialise counters
    @update_counter = 0
    @insert_counter = 0

    # Read input file
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.last

    # Read column indexes
    header = spreadsheet.row(3)
    object_class_index = header.index("Class") +1
    object_id_index = header.index("Object_Id") +1
    object_UUID_index = header.index("UUID") +1

    # For each language
    list_of_languages.order(:property).each do |locution|
      list_of_fields.each do |field|
        if phrase_index = header.index("#{field[0,4].capitalize}_#{locution.code}")+1 # Ignore if translation is not present in imported file
          # Loop through the spreadsheet
          (4..spreadsheet.last_row).map do |row_index|
            next if spreadsheet.cell(row_index, object_class_index).classify.constantize.find(spreadsheet.cell(row_index, object_id_index)).is_template
            if phrase = Translation.find_by(document_type: spreadsheet.cell(row_index, object_class_index),
                                            document_id: spreadsheet.cell(row_index, object_id_index),
                                            language: locution.property, field_name: field)
              @update_counter += 1
            else phrase = Translation.new(document_type: spreadsheet.cell(row_index, object_class_index),
                                          document_id: spreadsheet.cell(row_index, object_id_index),
                                          language: locution.property, field_name: field)
              @insert_counter += 1
            end
            phrase.translation = spreadsheet.cell(row_index, phrase_index) unless spreadsheet.cell(row_index, phrase_index).blank?
            puts phrase
            updated_translations << phrase
          end
        end
      end
    end
    updated_translations
  end

  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path, csv_options: {col_sep: ";"})
#    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
