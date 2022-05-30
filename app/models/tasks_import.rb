class TasksImport
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
    if imported_tasks.map(&:valid?).all?
      imported_tasks.each(&:save!)
      true
    else
      imported_tasks.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_tasks
    @imported_tasks ||= load_imported_tasks
  end

  def load_imported_tasks
    #puts open_spreadsheet.nil?
    spreadsheet = self.open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      import = Task.find_by_id(row["id"]) || Task.new
      import.attributes = row.to_hash
      ### create first translation for current_user if data is available
      #import.name_translations.build(field_name: 'name', language: language, translation: import.name) unless import.name.blank?
      #import.description_translations.build(field_name: 'description', language: language, translation: import.description) unless import.description.blank?

      puts "test"
      puts import.attributes
      import
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
