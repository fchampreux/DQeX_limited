class SkillsImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :parent_id

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_skills.map(&:valid?).all?
      imported_skills.each(&:save!)
      true
    else
      imported_skills.each_with_index do |import, index|
        import.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_skills
    @imported_skills ||= load_imported_skills
  end

  def load_imported_skills
    #puts open_spreadsheet.nil?
    spreadsheet = self.open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
=begin # variable number of languages does not allow to use transpose
      row = Hash[[header, spreadsheet.row(i)].transpose]
      import = Skill.find_by_id(row["id"]) || Skill.new
      import.attributes = row.to_hash
=end
      record = DeployedSkill.new
      record.business_object_id = parent_id
      record.is_template = false
      record.owner_id = record.parent.owner_id
      #record.owner_id = BusinesObject.find(parent_id).owner_id
      record.code = spreadsheet.cell(i,2).to_s
      record.name = spreadsheet.cell(i,3).to_s
      record.skill_type_id = Parameter.find_by_property(spreadsheet.cell(i,5)).id if Parameter.exists?(:property => (spreadsheet.cell(i,5)))
      record.skill_size = spreadsheet.cell(i,6).to_i
      record.skill_precision = spreadsheet.cell(i,7).to_i
      record.is_pk = spreadsheet.cell(i,8)
      record.is_published = spreadsheet.cell(i,9)
      record.is_mandatory = spreadsheet.cell(i,10)
      record.sensitivity_id = spreadsheet.cell(i,11).to_i
      record.name_translations.build(field_name: 'name', language: 'de_OFS', translation: spreadsheet.cell(i,12))
      record.description_translations.build(field_name: 'description', language: 'de_OFS', translation: spreadsheet.cell(i,13)) unless spreadsheet.cell(i,29).blank?
      record.name_translations.build(field_name: 'name', language: 'en', translation: spreadsheet.cell(i,14))
      record.description_translations.build(field_name: 'description', language: 'en_OFS', translation: spreadsheet.cell(i,15)) unless spreadsheet.cell(i,27).blank?
      record.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: spreadsheet.cell(i,16))
      record.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: spreadsheet.cell(i,17)) unless spreadsheet.cell(i,31).blank?
      record.name_translations.build(field_name: 'name', language: 'it_OFS', translation: spreadsheet.cell(i,18))
      record.description_translations.build(field_name: 'description', language: 'it_OFS', translation: spreadsheet.cell(i,19)) unless spreadsheet.cell(i,33).blank?
      record.created_by = 'admin'
      record.updated_by = 'admin'

      puts "test"
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
