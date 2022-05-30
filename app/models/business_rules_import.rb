class BusinessRulesImport
  include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include TranslationsHelper
  include ParametersHelper

  attr_accessor :file, :playground
  attr_reader :read_counter, :insert_counter, :tasks_counter, :importation_status

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_business_rules.map(&:valid?).all?
      imported_business_rules.each(&:save!)
      true
    else
      imported_business_rules.each_with_index do |import, index|
        import.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_business_rules
    @imported_business_rules ||= load_imported_business_rules
  end

  def load_imported_business_rules
    @read_counter = 0
    @insert_counter = 0
    @tasks_counter = 0
    #puts open_spreadsheet.nil?
    #current_language = 'en'
    spreadsheet = self.open_spreadsheet(file)
    spreadsheet.default_sheet = spreadsheet.sheets.last
    sequence_index = 1
    id_index = 2
    field_index = 3
    class_index = 5
    status_index = 6
    check_script_index = 7
    rule_type_index = 8
    rule_fr_index = 9
    rule_de_index = 10
    published_index = 11
    action_fr_index = 12
    action_de_index = 13
    task_Appl_index = 14
    task_SW_index = 15
    task_Import_index = 16

    # Create array of links
    imported_rules = Array.new

    header = spreadsheet.row(2)
    (3..spreadsheet.last_row).map do |i|
      #row = Hash[[header, spreadsheet.row(i)].transpose]
      @read_counter += 1

      puts "--- Target skill ---"
      puts spreadsheet.cell(i, field_index)

      # Trouver le parent et créer la règle
      if rule_skill = Skill.find_by_code(spreadsheet.cell(i, field_index))
        rule_parent = rule_skill.parent
        rule = rule_parent.business_rules.build(playground_id: rule_parent.playground_id,
                                          organisation_id: rule_parent.organisation_id,
                                          responsible_id: rule_parent.responsible_id,
                                          deputy_id: rule_parent.deputy_id,
                                          skill_id: rule_skill.id,
                                          major_version: 0,
                                          minor_version: 0,
                                          active_from: Time.now,
                                          workflow_state: 'new',
                                          is_template: false,
                                          created_by: rule_parent.created_by,
                                          updated_by: rule_parent.updated_by,
                                          owner_id: rule_parent.owner_id )
        rule.code = spreadsheet.cell(i, id_index)
        rule.ordering_sequence = spreadsheet.cell(i, sequence_index)
        rule.status_id = (statuses.find { |x| x["code"] == spreadsheet.cell(i, status_index) } ||
                          statuses.find { |x| x["code"] == "ACTIVE" }).id
        rule.rule_class_id = options_for('rules_classes').find { |x| x["code"] == spreadsheet.cell(i, class_index) }.id || 0
        rule.check_script = spreadsheet.cell(i, check_script_index)
        puts "- Rule type -"
        puts rule_type = spreadsheet.cell(i, rule_type_index)[spreadsheet.cell(i, rule_type_index).index('/')+2 .. -1].capitalize
        rule.rule_type_id = Translation.where("field_name = 'name' and translation = ?", rule_type).first.document_id
        rule.is_published = spreadsheet.cell(i, published_index).downcase.index('oui') ? false : true
        rule.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: spreadsheet.cell(i, id_index))
        rule.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: spreadsheet.cell(i, rule_fr_index))
        rule.name_translations.build(field_name: 'name', language: 'de_OFS', translation: spreadsheet.cell(i, id_index))
        rule.description_translations.build(field_name: 'description', language: 'de_OFS', translation: spreadsheet.cell(i, rule_de_index))
        rule.correction_method_translations.build(field_name: 'correction_method', language: 'fr_OFS', translation: spreadsheet.cell(i, action_fr_index))
        rule.correction_method_translations.build(field_name: 'correction_method', language: 'de_OFS', translation: spreadsheet.cell(i, action_de_index))
        rule.check_error_message_translations.build(field_name: 'check_error_message', language: 'fr_OFS', translation: spreadsheet.cell(i, action_fr_index))
        rule.check_error_message_translations.build(field_name: 'check_error_message', language: 'de_OFS', translation: spreadsheet.cell(i, action_de_index))
        added_task = rule.tasks.build(playground_id: rule.playground_id,
                                          organisation_id: rule.organisation_id,
                                          responsible_id: rule.responsible_id,
                                          deputy_id: rule.deputy_id,
                                          code: 'Action',
                                          owner_id: rule.owner_id)
        added_task.task_type_id = options_for('tasks_types').find { |x| x["code"] == 'ACTION' }.id || 0
        added_task.script = "sendmail #{rule.responsible.email}  < /tmp/email.txt"
        added_task.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: 'Action 4.1')
        added_task.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: spreadsheet.cell(i, action_fr_index))
        added_task.name_translations.build(field_name: 'name', language: 'de_OFS', translation: 'Aktion 4.1')
        added_task.description_translations.build(field_name: 'description', language: 'de_OFS', translation: spreadsheet.cell(i, action_de_index))
        @tasks_counter += 1
        added_task = rule.tasks.build(playground_id: rule.playground_id,
                                          organisation_id: rule.organisation_id,
                                          responsible_id: rule.responsible_id,
                                          deputy_id: rule.deputy_id,
                                          code: 'Appl',
                                          owner_id: rule.owner_id)
        added_task.task_type_id = options_for('tasks_types').find { |x| x["code"] == 'Appl' }.id || 0
        added_task.script = spreadsheet.cell(i, task_Appl_index)
        added_task.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: spreadsheet.cell(i, task_Appl_index))
        added_task.name_translations.build(field_name: 'name', language: 'de_OFS', translation: spreadsheet.cell(i, task_Appl_index))
        added_task.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: spreadsheet.cell(i, task_Appl_index))
        added_task.description_translations.build(field_name: 'description', language: 'de_OFS', translation: spreadsheet.cell(i, task_Appl_index))
        @tasks_counter += 1
        added_task = rule.tasks.build(playground_id: rule.playground_id,
                                          organisation_id: rule.organisation_id,
                                          responsible_id: rule.responsible_id,
                                          deputy_id: rule.deputy_id,
                                          code: 'SW',
                                          owner_id: rule.owner_id)
        added_task.task_type_id = options_for('tasks_types').find { |x| x["code"] == 'SW' }.id || 0
        added_task.script = spreadsheet.cell(i, task_SW_index)
        added_task.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: spreadsheet.cell(i, task_SW_index))
        added_task.name_translations.build(field_name: 'name', language: 'de_OFS', translation: spreadsheet.cell(i, task_SW_index))
        added_task.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: spreadsheet.cell(i, task_SW_index))
        added_task.description_translations.build(field_name: 'description', language: 'de_OFS', translation: spreadsheet.cell(i, task_SW_index))
        @tasks_counter += 1
        added_task = rule.tasks.build(playground_id: rule.playground_id,
                                          organisation_id: rule.organisation_id,
                                          responsible_id: rule.responsible_id,
                                          deputy_id: rule.deputy_id,
                                          code: 'Import',
                                          owner_id: rule.owner_id)
        added_task.task_type_id = options_for('tasks_types').find { |x| x["code"] == 'Import' }.id || 0
        added_task.script = spreadsheet.cell(i, task_Import_index)
        added_task.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: spreadsheet.cell(i, task_Import_index))
        added_task.name_translations.build(field_name: 'name', language: 'de_OFS', translation: spreadsheet.cell(i, task_Import_index))
        added_task.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: spreadsheet.cell(i, task_Import_index))
        added_task.description_translations.build(field_name: 'description', language: 'de_OFS', translation: spreadsheet.cell(i, task_Import_index))
        @tasks_counter += 1

        imported_rules << rule
        @insert_counter += 1
      puts "####################### test ####################################"
      puts rule.attributes
      end
    end
    puts @read_counter
    puts @insert_counter
    puts @tasks_counter
    @importation_status = "#{@insert_counter + @tasks_counter} \n
    Lines read: #{@read_counter} \n
    Rules: #{@insert_counter} \n
    Tasks: #{@tasks_counter}"

    imported_rules
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
