# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  playground_id   :bigint
#  description     :text
#  severity_id     :integer          not null
#  status_id       :integer          default(0)
#  expected_at     :datetime
#  closed_at       :datetime
#  responsible_id  :integer          not null
#  owner_id        :integer          not null
#  created_by      :string(255)      not null
#  updated_by      :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  topic_type      :string
#  topic_id        :bigint
#  workflow_state  :string
#  deputy_id       :integer
#  organisation_id :integer
#  name            :string(255)
#  code            :string(255)
#  is_active       :boolean          default(TRUE)
#

class Notification < ApplicationRecord
###############################################################################
# A notification is a message related to an event occuring on an object.      #
# The notification is linked to the related object thanks to the topic        #
# polymorphic relationship attributes. It is usually involved in a validation #
# workflow, version creation workflow, or object modification events.         #
# The notification is Owned by the user who triggered the event, and has for  #
# destination the Responsible person (and person's main Group - Hauptgruppe)  #
# for the subsequent action to take.                                          #
###############################################################################



# Manage finite state machine
  include WorkflowActiverecord
  workflow do
    state :new
      event :open, :transitions_to => :viewed
    state :viewed
      #event :start, :transitions_to => :wip
      #event :assign, :transitions_to => :new
      event :close, :transitions_to => :closed
=begin
    state :wip
      event :solve, :transitions_to => :closed
      event :hold, :transitions_to => :on_hold
      event :close, :transitions_to => :closed
    state :solved
      event :restart, :transitions_to => :wip
      event :archive, :transitions_to => :archived
    state :on_hold
      event :restart, :transitions_to => :wip
=end
    state :closed
      #event :restart, :transitions_to => :wip
      #event :archive, :transitions_to => :archived
    #state :archived
  end

### scope
  scope :responsible, ->(user) { where "responsible_id=? ", user }

  ### validations
  validates :code,        presence: true,  length: { maximum: 100 }
  validates :created_by,  presence: true
  validates :updated_by,  presence: true
  validates :owner,       presence: true
  validates :parent,      presence: true
  validates :severity_id, presence: true
  validates :status_id,   presence: true
  validates :expected_at, presence: true
  belongs_to :parent, :class_name => "Playground", :foreign_key => "playground_id"
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
	belongs_to :responsible, :class_name => "User", :foreign_key => "responsible_id"	# helps retrieving the responible name	belongs_to :responsible,  :class_name => "User", :foreign_key => "responsible_id"		# helps retrieving the responsible name
	belongs_to :deputy,       :class_name => "User", :foreign_key => "deputy_id"		# helps retrieving the deputy name
	belongs_to :organisation, :class_name => "Organisation", :foreign_key => "organisation_id"		# helps retrieving the organisation in charge
	belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"		# helps retrieving the status name
	belongs_to :severity, :class_name => "Parameter", :foreign_key => "severity_id"		# helps retrieving the severity grade
	belongs_to :topic, polymorphic: true	                                                      # helps retrieving the business object name

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']
	has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
end
