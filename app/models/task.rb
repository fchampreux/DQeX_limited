# == Schema Information
#
# Table name: tasks
#
#  id                 :bigint           not null, primary key
#  playground_id      :bigint
#  parent_type        :string
#  parent_id          :bigint
#  organisation_id    :integer          default(0)
#  responsible_id     :integer          default(0)
#  deputy_id          :integer          default(0)
#  code               :string(255)      not null
#  name               :string(255)
#  description        :text
#  hierarchy          :string(255)      not null
#  pcf_index          :string(255)
#  pcf_reference      :string(255)
#  task_type_id       :integer          default(0)
#  script             :text
#  script_language_id :integer          default(0)
#  external_reference :string(255)
#  status_id          :integer          default(0)
#  owner_id           :integer          not null
#  is_finalised       :boolean          default(TRUE)
#  is_current         :boolean          default(TRUE)
#  is_active          :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Task < ApplicationRecord
# include ParametersHelper for testing node_type
extend CsvHelper
audited

### global identifier
  self.sequence_name = "global_seq"
  self.primary_key = "id"

### before filter
  before_create :set_hierarchy
  before_validation :set_code

  validates :code, presence: true, uniqueness: {:scope => [:parent_type, :parent_id], case_sensitive: false}, length: { maximum: 32 }
	validates :parent, presence: true
	validates :task_type, presence: true
  validates :playground_id,    presence: true
  validates :owner_id,    presence: true
  validates :status_id,    presence: true
	validates :pcf_index, length: { maximum: 30 }
	validates :pcf_reference, length: { maximum: 100 }
  validate :task_compliance
	belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
	belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
	belongs_to :task_type, :class_name => "Parameter", :foreign_key => "task_type_id"	# helps retrieving the status name
	belongs_to :script_language, :class_name => "Parameter", :foreign_key => "script_language_id", optional: true	# helps retrieving the development language name
	belongs_to :statement_language, :class_name => "Parameter", :foreign_key => "statement_language_id", optional: true	# helps retrieving the operating language name
  belongs_to :template, optional: true, class_name: "Task", foreign_key: :template_id # References an activity used as a template
  belongs_to :technology, class_name: "Value", foreign_key: :technology_id
  belongs_to :gsbpm, optional: true,  class_name: "Value", :foreign_key => "gsbpm_id"	# helps retrieving the gsbpm process code
  belongs_to :source_object, class_name: "DeployedObject", foreign_key: :source_object_id
  belongs_to :target_object, class_name: "DeployedObject", foreign_key: :target_object_id
  belongs_to :success_next, class_name: "Task", foreign_key: :success_next_id
  belongs_to :failure_next, class_name: "Task", foreign_key: :failure_next_id
	belongs_to :node_type, :class_name => "Parameter", :foreign_key => "node_type_id"	# helps retrieving the status name
	belongs_to :parent, polymorphic: true

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']
	has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true


### private functions definitions

  def set_hierarchy
#    self.playground_id = self.todo.playground_id
    if Task.where("parent_id = ? and parent_type = ?", self.parent_id, self.parent_type).count == 0
      self.hierarchy = self.parent.hierarchy + '.001'
    else
      last_one = Task.where("parent_id = ? and parent_type = ?", self.parent_id, self.parent_type).maximum("hierarchy")
      self.hierarchy = last_one.next
    end
  end

  def task_compliance
    # Check that Start, End and Rescue tasks are present, even when destroy is invoked
  end

end
