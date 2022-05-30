# == Schema Information
#
# Table name: groups
#
#  id              :integer          not null, primary key
#  playground_id   :bigint
#  code            :string(255)      not null
#  name            :string(255)
#  description     :text
#  territory_id    :integer          not null
#  organisation_id :integer          not null
#  is_active       :boolean          default(TRUE)
#  status_id       :integer          default(0)
#  owner_id        :integer          not null
#  created_by      :string(255)      not null
#  updated_by      :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  hierarchy_entry :string(255)
#

class Group < ApplicationRecord
audited

### Validations
  validates :code,        presence: true, uniqueness: {case_sensitive: false}, length: { maximum: 32 }
  validates :created_by , presence: true
  validates :updated_by,  presence: true
  validates :organisation_id, presence: true
  validates :territory_id,    presence: true
  validates :owner_id,    presence: true
  belongs_to :owner,  :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :territory # helps retrieving the territory name
  belongs_to :organisation  # helps retrieving the organisation name

  # Relations
  has_many :groups_users
  has_many :groups_roles
  has_and_belongs_to_many :users
  has_and_belongs_to_many :roles, :class_name => "Parameter", :join_table => "groups_roles"

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'description']
	has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true
end
