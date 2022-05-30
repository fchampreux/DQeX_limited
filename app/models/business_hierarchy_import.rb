class BusinessHierarchyImport
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
    if imported_business_hierarchies.map(&:valid?).all?
      imported_business_hierarchies.each(&:save!)
      true
    else
      imported_business_hierarchies.each_with_index do |column, index|
        column.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_business_hierarchies
    ActiveRecord::Base.connection.execute("DELETE from dqm_app.business_hierarchies")
    @imported_business_hierarchies ||= load_imported_business_hierarchies
  end

  def load_imported_business_hierarchies
    #puts open_spreadsheet.nil?
    puts "File load"
    assigned_playground = Playground.find(playground) # parameter from the New view
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = 'Combined'
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      record = BusinessHierarchy.new
      record.playground_id = assigned_playground.id
      record.pcf_index = spreadsheet.cell(i,1)
      record.pcf_reference = spreadsheet.cell(i,2)
      # For OFS, hierarchical level increased by 1 due concatenation with playground code. Then remove 1 (could be linked to multi-tenancy option)
      record.hierarchical_level = case spreadsheet.cell(i,2).last(3)
          when '.00' then spreadsheet.cell(i,2).count('.')
          else spreadsheet.cell(i,2).count('.')+1
        end -1 # OFS
      record.hierarchy = spreadsheet.cell(i,2)[3..-1].gsub('.00','').split('.').inject(assigned_playground.hierarchy) do |result, t| # [3..-1] remove OFS playground code
          result + '.' + t.rjust(3, '0')
        end
      record.name = spreadsheet.cell(i,3)
      # record.name_en = spreadsheet.cell(i,8)
      record.name_fr = spreadsheet.cell(i,9)
      record.name_de = spreadsheet.cell(i,10)
      record.name_it = spreadsheet.cell(i,11)
      # Depending on source, Desciption is stored in a comment or in a cell
      record.description = spreadsheet.comment(i,3, spreadsheet.sheets[13]) || spreadsheet.cell(i,4)
      # record.description_en = spreadsheet.cell(i,12)
      record.description_fr = spreadsheet.cell(i,13)
      record.description_de = spreadsheet.cell(i,14)
      record.description_it = spreadsheet.cell(i,15)
      ### OFS
      record.responsible = spreadsheet.cell(i,5)
      record.field = spreadsheet.cell(i,6)
      record.funding = spreadsheet.cell(i,7)
      ### OFS

      record
    end
  end

  def open_spreadsheet(file)
    puts "File Import"
    case File.extname(file.original_filename)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
