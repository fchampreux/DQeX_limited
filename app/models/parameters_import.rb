class ParametersImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include TranslationsHelper
  include SessionsHelper

  attr_accessor :file, :parent_id

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_parameters.map(&:valid?).all?
      imported_parameters.each(&:save!)
      true
    else
      imported_parameters.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_parameters
    @imported_parameters ||= load_imported_parameters
  end

  def load_imported_parameters
    # Based on business languages defined in related parameters list
    puts "File load"
    @update_counter = 0
    @insert_counter = 0
    list = ParametersList.find(parent_id)
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = 'Parameters'
    header = spreadsheet.row(1)
    code_index = header.index("code") +1
    scope_index = (header.index("scope") || -1) +1
    property_index = (header.index("property") || -1) +1
    active_from_index = (header.index("active_from") || -1) +1
    active_to_index = (header.index("active_to") || -1) +1
    sort_code_index = (header.index("sort_code") || -1) +1

    (2..spreadsheet.last_row).map do |row_index|
      # Create or update parameter based on code
      if record = Parameter.find_by(parameters_list_id: list.id, code: spreadsheet.cell(row_index, code_index))
        @update_counter += 1
      else
        record = list.parameters.build(code: spreadsheet.cell(row_index, code_index))
        @insert_counter += 1
      end
      record.property = (property_index == 0 ? nil : spreadsheet.cell(row_index, property_index).to_s)
      record.scope =  (scope_index == 0 ? nil : spreadsheet.cell(row_index, scope_index))
      record.active_from = (active_from_index == 0 ? Time.now : spreadsheet.cell(row_index, active_from_index))
      record.active_to = (active_to_index == 0 ? Time.now + 1.year : spreadsheet.cell(row_index, active_to_index))
      record.sort_code = (sort_code_index == 0 ? nil : spreadsheet.cell(row_index, sort_code_index))

      # Add translations
      list_of_languages.order(:property).each do |locution|
        if header.index("Name_#{locution.code}") # Ignore if translation is not present in imported file
          name_index = header.index("Name_#{locution.code}") +1
          description_index = header.index("Description_#{locution.code}") +1
          if name = Translation.find_by(document_type: 'Parameter', document_id: record.id, field_name: 'name', language: locution.property)
            name.update_attribute(:translation, spreadsheet.cell(row_index,name_index))
          else
            record.name_translations.build(field_name: 'name', language: locution.property, translation: spreadsheet.cell(row_index,name_index))
          end
          if description = Translation.find_by(document_type: 'Parameter', document_id: record.id, field_name: 'description', language: locution.property)
            description.update_attribute(:translation, spreadsheet.cell(row_index,description_index))
          else
            record.description_translations.build(field_name: 'description', language: locution.property, translation: spreadsheet.cell(row_index,description_index))
          end
        end
      end


      puts "####################### test ####################################"
      puts record.attributes

      record

    end
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
