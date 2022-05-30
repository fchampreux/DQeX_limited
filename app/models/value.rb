# == Schema Information
#
# Table name: values
#
#  id             :integer          not null, primary key
#  values_list_id :bigint
#  code           :string(255)      not null
#  name           :string(255)
#  description    :text
#  level          :integer          default(1), not null
#  parent_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  playground_id  :bigint
#  alternate_code :string(255)
#  alias          :string(255)
#  abbreviation   :string(255)
#  anything       :json
#

class Value < ApplicationRecord
extend CsvHelper

# This virtual attribute allows user to ignore parent value id
attr_accessor :parent_code
#attr_accessor :classification_id

### before filter
before_save :set_parent_id # user only inputs parent code when building a hierarchy
after_save :touch_values_list

### alias to identifiy the container object belongs to
#  alias_attribute :container, :values_list

### validation
  validates :code,   presence: true, uniqueness: {scope: :values_list_id, case_sensitive: false}, length: { maximum: 32 }
  validates :parent, presence: true
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"		# helps retrieving the owner name
  belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
  belongs_to :language, :class_name => "Parameter", :foreign_key => "language_id"	# helps retrieving the development language name
  belongs_to :parent, :class_name => "ValuesList", :foreign_key => "values_list_id"
	belongs_to :superior, :class_name => "Value", :foreign_key => :parent_id
  has_many :subs, :class_name => "Value", :foreign_key => :parent_id, :dependent => :destroy
  has_many :values_to_values
  has_many :child_values, through: :values_to_values

  ### annotations
  has_many :annotations, as: :object_extra, :dependent => :destroy
  accepts_nested_attributes_for :annotations, :reject_if => :all_blank, :allow_destroy => true

  ### Translation support
  mattr_accessor :translated_fields, default: ['name', 'alias', 'abbreviation', 'description']
	has_many :translations, as: :document
  has_many :name_translations, -> { where(field_name: 'name') }, class_name: 'Translation', as: :document
  has_many :alias_translations, -> { where(field_name: 'alias') }, class_name: 'Translation', as: :document
  has_many :abbreviation_translations, -> { where(field_name: 'abbreviation') }, class_name: 'Translation', as: :document
  has_many :description_translations, -> { where(field_name: 'description') }, class_name: 'Translation', as: :document
  accepts_nested_attributes_for :translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :name_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :alias_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :abbreviation_translations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :description_translations, :reject_if => :all_blank, :allow_destroy => true

### private functions definitions
  private

	### before filters
	def set_parent_id
		self.level = 1
		#puts "Before filter"
		#puts self.parent_code
    if not self.parent_code.blank?
			puts "Search for parent"
			@parent = Value.where("code = ? and values_list_id = ?", self.parent_code.to_s, self.values_list_id).first
      if @parent
			  self.parent_id = @parent.id
			  self.level = @parent.level.next
      else
			  self.parent_id = nil
			  self.level = 1
      end
		end
	end

  def touch_values_list
    self.parent.update_attribute(:updated_at, Time.now)
  end

end
