class UsersImport
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
    if imported_values.map(&:valid?).all?
      imported_values.each(&:save!)
      true
    else
      imported_values.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          puts message
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
    puts "File load"
    imported_users = Array.new
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = 'Users'
    header = spreadsheet.row(1)
    organisation_index = header.index("organisation_code") +1
    (2..spreadsheet.last_row).map do |i|
      # Prepare password
      password = "DQ_1st!-#{i}" # Simple password, matching the index of MS Excel import file

      # Search for existing user by email, or create new one
      next if User.exists?(user_name: spreadsheet.cell(i,4).to_s)

      # Read the imported row, but only for known attributes
      row = Hash[[header, spreadsheet.row(i)].transpose].except('main_group', 'owner_name', 'organisation_code', 'organisation_name', 'activity_status')
      record = User.new
      record.attributes = row # Assign imported attributes known by the model
      record.id = nil         # Username has not been found, reset id
      #record.user_name = spreadsheet.cell(i,1).to_s
      #record.first_name = spreadsheet.cell(i,2).to_s
      #record.last_name = spreadsheet.cell(i,3).to_s
      #record.email = spreadsheet.cell(i,4).to_s
      record.organisation_id = spreadsheet.cell(i,organisation_index).blank? ? 0 : (Organisation.find_by_code(spreadsheet.cell(i,organisation_index).to_s) || Organisation.find_by_code('UNDEFINED')).id
      record.current_playground_id = playground
      record.playground_id = 0
      #record.external_directory_id = spreadsheet.cell(i,6).to_s
      #record.language = spreadsheet.cell(i,7).to_s
      #record.active_from = spreadsheet.cell(i,8) || Time.now
      #record.active_to = spreadsheet.cell(i,9) || Time.now + 365.days
      record.created_by = record.created_by ||'Administrator'
      record.updated_by = 'Administrator'
      record.owner_id = 1 # Administrator
      record.password = password
      record.password_confirmation = password
      record.sign_in_count = 0
      record.failed_attempts = 0
      record.active_from ||= Time.now
      record.active_to ||= record.active_from + 1.year

      # Add main group
      record.groups_users.build(group_id: 0, is_principal: true, active_from: record.active_from, active_to: record.active_to)

      # Add description translations
      next_cell = 10
      ApplicationController.helpers.list_of_languages.order(:property).each do |translation|
        record.description_translations.build(field_name: 'description', language: translation.property, translation: record.name)
        next_cell += 1
      end
      puts "####################### test ####################################"
      puts record.attributes

      imported_users << record
    end
    imported_users
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
