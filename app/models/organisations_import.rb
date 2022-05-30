class OrganisationsImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :playground

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_organisations.map(&:valid?).all?
      imported_organisations.each(&:save!)
      true
    else
      imported_organisations.each_with_index do |record, index|
        record.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_organisations
    @imported_organisations ||= load_imported_organisations
  end

  def load_imported_organisations
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = 'Organisations'
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      record = Organisation.new
      record.playground_id = $Unicity ? 0 : playground # If only one tenant, then the organisations belong to Governance
      record.code = spreadsheet.cell(i,1).to_s
      record.name = spreadsheet.cell(i,6)
      record.parent_code = spreadsheet.cell(i,2).to_s # before_save action sets the parent_id
      record.organisation_level = spreadsheet.cell(i,3) # overwriten by the before_save action
      record.created_by = 'admin'
      record.updated_by = 'admin'
      record.owner_id = 1 # Administrator
      record.status_id = Parameter.find_by_name("New").id if Parameter.exists?(:name => ("New"))

      # Add description translations
      next_cell = 6
      ApplicationController.helpers.list_of_languages.order(:property).each do |translation|
        record.description_translations.build(field_name: 'name', language: translation.property, translation: spreadsheet.cell(i,next_cell))
        next_cell += 1
        record.description_translations.build(field_name: 'description', language: translation.property, translation: spreadsheet.cell(i,next_cell))
        next_cell += 1
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
