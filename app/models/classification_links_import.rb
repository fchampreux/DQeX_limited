class ClassificationLinksImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include TranslationsHelper

  attr_accessor :file, :parent_id, :allow_scan_up
  attr_reader :update_counter, :insert_counter, :links_counter

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_classification_links.map(&:valid?).all?
      imported_classification_links.each(&:save!)
      true
    else
      imported_classification_links.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_classification_links
    @imported_classification_links ||= load_imported_classification_links
  end

  def load_imported_classification_links
    # Initialise counters
    @update_counter = 0
    @insert_counter = 0
    @links_counter = 0

    # Get the list of values lists to upload
    @classification = Classification.find(parent_id)
    playground_id = @classification.playground_id
    values_lists = Array.new
    @classification.values_lists_classifications.where("level > 0").order(:level).each do |link|
      values_lists[link.level] = link.values_list_id
    end

    # Read input file
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.last

    # Read columns indexes
    header = spreadsheet.row(1)
    parent_index = header.index("Parent") +1
    level_index = header.index("Level") +1
    code_index = header.index("Code") +1
    valid_from_index = (header.index("Valid from") || -1) +1 # This column usually does not exist
    valid_to_index = (header.index("Valid to") || -1) +1 # This column usually does not exist
    event_index = (header.index("Event") || -1) +1 # This column usually does not exist

    # Delete all existing links
    ValuesToValue.where("classification_id = ?", @classification.id).delete_all

    # Create array of links
    linked_values = Array.new

    # start loading links for each values list
    (2..spreadsheet.last_row).map do |i|

      # Skip if parent is blank
      next if spreadsheet.cell(i, parent_index).blank?

      # Count links to report when finished
      @links_counter += 1

      # Skip if the value not found
      child_values_list_id = values_lists[spreadsheet.cell(i, level_index).to_i]
      next if not (child_value = Value.find_by(values_list_id: child_values_list_id, code: spreadsheet.cell(i, code_index).to_s))

      # Skip if the parent value is not found, or scan if allow_scan_up
      parent_level = (spreadsheet.cell(i, level_index).to_i) -1
      until parent_level == 0
        values_list_id = values_lists[parent_level]
        break if (value = Value.find_by(values_list_id: values_list_id, code: spreadsheet.cell(i, parent_index).to_s) or not :allow_scan_up)
        parent_level -= 1
      end
      next if not value

      link_code = "#{values_list_id}/#{spreadsheet.cell(i, parent_index)} - #{child_values_list_id}/#{spreadsheet.cell(i, code_index)}"
      link_name = (event_index = 0 ? "#{spreadsheet.cell(i, parent_index)} #{spreadsheet.cell(i, code_index)}" : spreadsheet.cell(i,event_index)).to_s

      link = ValuesToValue.new( playground_id: playground_id,
                                    classification_id: @classification.id,
                                    values_list_id: values_list_id,
                                    child_values_list_id: child_values_list_id,
                                    value_id: value.id,
                                    child_value_id: child_value.id,
                                    code: link_code,
                                    name: link_name,
                                    type_id: 0 # Should retrieve the corresponding parameter
                                  )

                                  link.active_from = (valid_from_index = 0 ? nil : spreadsheet.cell(i,valid_from_index))
                                  link.active_to = (valid_to_index = 0 ? nil : spreadsheet.cell(i,valid_to_index))

                                  # Add translations
                                  list_of_languages.order(:property).each do |locution|
                                    if header.index("Desc_#{locution.code}") # Ignore if translation is not present in imported file
                                      description_index = header.index("Desc_#{locution.code}") +1
                                      link.name_translations.build(field_name: 'name', language: locution.property, translation: link_name)
                                      link.description_translations.build(field_name: 'description', language: locution.property, translation: spreadsheet.cell(i,description_index))
                                    end
                                  end

      linked_values << link

      puts "####################### test ####################################"
      puts link.attributes
    end
    linked_values
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
