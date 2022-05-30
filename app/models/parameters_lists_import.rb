class ParametersListsImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ParametersHelper
  include TranslationsHelper

  attr_accessor :file, :language, :playground
  attr_reader :read_counter, :insert_counter, :importation_status, :parent_id

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_parameters_lists.map(&:valid?).all?
      imported_parameters_lists.each(&:save!)
      # Import embedded parameters too
      @imported_parameters = ParametersImport.new(file: file, parent_id: @parent_id)
      if @imported_parameters.save
        @importation_status = "Successful import"
        true
      else
        @importation_status = "Failed importing parameters"
        true
      end
    else
      imported_parameters_lists.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_parameters_lists
    @imported_parameters_lists ||= load_imported_parameters_lists
  end

  def load_imported_parameters_lists
    # open input file
    puts "File load"
    @update_counter = 0
    @insert_counter = 0
    spreadsheet = self.open_spreadsheet(file)

    # Parameters list attribues positions in spreadsheet
    spreadsheet.default_sheet = 'Parameters list'
    list_id = spreadsheet.cell(2,2)
    list_code = spreadsheet.cell(3,2)
    is_active_flag = spreadsheet.cell(7,2)
    status_code = spreadsheet.cell(8,2)
    owner_user_name = spreadsheet.cell(9,2)
    sort_code = spreadsheet.cell(14,2)

    # update or create
    if record = ParametersList.find_by(code: list_code)
      # No attribute update makes sense for an already used list of parameters
      @update_counter += 1
    else
      record = ParametersList.create(code: list_code,
                                    name: list_code,
                                    status_id: (statuses.find { |x| x["code"] == status_code } || Parameter.find(0)).id,
                                    owner_id: (User.where(user_name: owner_user_name).take || User.find(0)).id,
                                    is_active: is_active_flag,
                                    created_by: 'Admin',
                                    updated_by: 'Admin',
                                    sort_code: sort_code)
      @insert_counter += 1
    end

    # Add translations based on business languages defined in related parameters list
    languages_row = 4
    languages_header = spreadsheet.row(languages_row)
    list_of_languages.order(:property).each do |locution|
      if languages_header.index(locution.code) # Ignore if translation is not present in imported file
        caption_index = languages_header.index(locution.code) +1
        if name = Translation.find_by(document_type: 'ParametersList',
                                      document_id: record.id,
                                      field_name: 'name',
                                      language: locution.property)
          name.update_attribute(:translation, spreadsheet.cell(languages_row + 1, caption_index))
        else
          record.name_translations.build(field_name: 'name',
                                        language: locution.property,
                                        translation: spreadsheet.cell(languages_row + 1, caption_index))
        end
        if description = Translation.find_by(document_type: 'ParametersList',
                                            document_id: record.id,
                                            field_name: 'description',
                                            language: locution.property)
          description.update_attribute(:translation, spreadsheet.cell(languages_row + 2, caption_index))
        else
          record.description_translations.build(field_name: 'description',
                                                language: locution.property,
                                                translation: spreadsheet.cell(languages_row + 2, caption_index))
        end
      end
    end

    puts "####################### test ####################################"
    puts record.attributes
    @importation_status = "Success"
    @parent_id = record.id

    parameters_lists = Array[ record ]
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
