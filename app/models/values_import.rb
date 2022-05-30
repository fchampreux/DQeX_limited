class ValuesImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include TranslationsHelper
  include AnnotationsHelper
  include SessionsHelper

  attr_accessor :file, :parent_id

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_values.map(&:valid?).all?
      imported_values.each(&:save!)
      true
    else
      imported_values.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_values
    @imported_values ||= load_imported_values
  end

  def load_imported_values

    # Initialise counters
    @update_counter = 0
    @insert_counter = 0

    # Get parent values list
    @values_list = ValuesList.find(parent_id)
    playground_id = @values_list.playground_id

    # Set updatable flag
    is_updatable = !@values_list.is_finalised

    # Read input file
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.last

    # Read column indexes
    header = spreadsheet.row(1)
    code_index = header.index("Code") +1
    parent_index = (header.index("Parent") || -1) +1
    level_index = (header.index("Level") || -1) +1
    valid_from_index = (header.index("Valid from") || -1) +1 # This column usually does not exist
    valid_to_index = (header.index("Valid to") || -1) +1 # This column usually does not exist
    uri_index = (header.index("Uri") || -1) +1 # This column usually does not exist
    alternate_code_index = (header.index("Alternate_code") || -1) +1 # This column usually does not exist

    # Annotations can be found after all translations
    annotations_list = Array.new

    next_index = 0 # index of first annotation column, if any
    current_index = 0 # index of description translation position
    last_index = spreadsheet.last_column # index of last annotation column

    list_of_languages.order(:property).each do |locution| # scan translations columns
      current_index = (header.index("Desc_#{locution.code}") || -1) +1
      next_index = current_index > next_index ? current_index : next_index
    end
    annotation_index = next_index + (uri_index == 0 ? 1 : 2) # Skips one nore column if uri column is present

    # Set the list of annotations to create
    (annotation_index..last_index).each do |index|
      column_name = spreadsheet.cell(1, index)
      underscore_index = column_name.rindex('_') || column_name.length # The last _ marks the field of the annotation if any
      annotation_name = column_name[0, underscore_index]
      annotations_list |= [annotation_name] # Adds new annotations only
    end

    puts "####################### indexes ####################################"
    puts next_index
    puts current_index
    puts last_index
    puts uri_index

    annotations_list.map {|column| puts column} # liste des annotations

    # start loading
    (2..spreadsheet.last_row).map do |row_index|

      # Create or update value based on code
      if value = Value.find_by(values_list_id: @values_list.id, code: spreadsheet.cell(row_index, code_index)) and is_updatable
        @update_counter += 1
      else value = Value.new(playground_id: playground_id, values_list_id:  @values_list.id, code: spreadsheet.cell(row_index, code_index))
        @insert_counter += 1
      end

      # Optional fields
      value.parent_code = (parent_index == 0 ? nil : spreadsheet.cell(row_index, parent_index))
      value.level = (level_index == 0 ? nil : spreadsheet.cell(row_index, level_index))
      value.active_from = (valid_from_index == 0 ? nil : spreadsheet.cell(row_index, valid_from_index))
      value.active_to = (valid_to_index == 0 ? nil : spreadsheet.cell(row_index, valid_to_index))
      value.uri = (uri_index == 0 ? nil : spreadsheet.cell(row_index, uri_index))
      value.alternate_code = (alternate_code_index == 0 ? nil : spreadsheet.cell(row_index, alternate_code_index))

      # Trace
      puts "--- Optional fields"
      puts value.parent_code
      puts value.level
      puts value.active_from
      puts value.active_to
      puts value.uri
      puts value.alias
      puts "---"

      # Add translations
      list_of_languages.order(:property).each do |locution|
        if header.index("Name_#{locution.code}") # Ignore if translation is not present in imported file
          name_index = header.index("Name_#{locution.code}") +1
          if name = Translation.find_by(document_type: 'Value', document_id: value.id, field_name: 'name', language: locution.property)
            name.update_attribute(:translation, spreadsheet.cell(row_index, name_index))
          else
            value.name_translations.build(field_name: 'name', language: locution.property, translation: spreadsheet.cell(row_index, name_index))
          end
        end
        if header.index("Desc_#{locution.code}") # Ignore if translation is not present in imported file
          description_index = header.index("Desc_#{locution.code}") +1
          if description = Translation.find_by(document_type: 'Value', document_id: value.id, field_name: 'description', language: locution.property)
            description.update_attribute(:translation, spreadsheet.cell(row_index, description_index))
          else
            value.description_translations.build(field_name: 'description', language: locution.property, translation: spreadsheet.cell(row_index, description_index))
          end
        end
      end

      # Add annotations
      # Specific process to import anotations generated by SMS export
      annotations_list.each do |column|

        ### Check if any content is available for this annotation : attributes and translations
        content_flag = 0
        # Detect annotation's attributes if any
        if type_index = header.index("#{column}_Type")
          content_flag += spreadsheet.cell(row_index, type_index +1).blank? ? 0 : 1
        end
        if name_index = header.index("#{column}_Title")
          content_flag += spreadsheet.cell(row_index, name_index +1).blank? ? 0 : 1
        end
        if description_index = header.index("#{column}_Text")
        content_flag += spreadsheet.cell(row_index, description_index +1).blank? ? 0 : 1
        end
        if annotation_uri_index = header.index("#{column}_Uri")
          content_flag += spreadsheet.cell(row_index, uri_index +1).blank? ? 0 : 1
        end

        # Detect annotation's translations if any
        list_of_languages.order(:property).each do |locution|
          if description_index = header.index("#{column}_#{locution.code}") # Ignore if translation is not present in imported file
            #description_index = header.index("#{column}_#{locution.code}")
            content_flag += spreadsheet.cell(row_index, description_index +1).blank? ? 0 : 1
          end
        end
        # Trace
        puts "--- Annotation fields count"
        puts content_flag
        puts "---"

        next if content_flag == 0
        ###

        # Add annotation
        if not annotation = Annotation.find_by(object_extra_type: 'Value', object_extra_id: value.id, name: column )
          annotation = value.annotations.build( playground_id: value.playground_id,
                                                code: column.gsub(/[^0-9A-Za-z]/, '-').upcase,
                                                name: column,
                                                annotation_type_id: ( annotation_types.find { |x| column.start_with?(x["code"]) } ||
                                                                      annotation_types.find { |x| x["code"] == 'OTHER' }).id)

          # Detect annotation's attributes if any
          if type_index = header.index("#{column}_Type")
            annotation.code = spreadsheet.cell(row_index, type_index +1).gsub(/[^0-9A-Za-z]/, '-').upcase
          end
          if name_index = header.index("#{column}_Title")
            annotation.name = spreadsheet.cell(row_index, name_index +1)
          end
          if description_index = header.index("#{column}_Text")
            annotation.description = spreadsheet.cell(row_index, description_index +1)
          end
          if annotation_uri_index = header.index("#{column}_Uri")
            annotation.uri = spreadsheet.cell(row_index, annotation_uri_index +1)
          end
        end
        # Trace
        puts "--- Annotation fields"
        puts annotation.code
        puts annotation.name
        puts annotation.description
        puts annotation.uri

        # Add annotation translations
        list_of_languages.order(:property).each do |locution|
          if description_index = header.index("#{column}_#{locution.code}") # Ignore if translation is not present in imported file
            #description_index = header.index("#{column}_#{locution.code}") +1
            if description = Translation.find_by(document_type: 'Annotation', document_id: annotation.id, field_name: 'description', language: locution.property)
              description.update_attribute(:translation, spreadsheet.cell(row_index, description_index +1))
            else
              annotation.description_translations.build(field_name: 'description', language: locution.property, translation: spreadsheet.cell(row_index, description_index +1))
            end
          else
            #annotation.description_translations.build(field_name: 'description', language: locution.property, translation: nil)
            #this is not needed anymore, due to check_translations function call before displaying translated fields
          end
        end
      end

      value
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
