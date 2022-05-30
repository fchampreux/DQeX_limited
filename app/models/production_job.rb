class ProductionJob < ApplicationRecord
  ### validations
    validates :code,        presence: true
    validates :created_by , presence: true
    validates :updated_by,  presence: true
    validates :owner_id,    presence: true
    validates :parent,      presence: true
  	validates :playground_id, presence: true
    belongs_to :parent, :class_name => "BusinessProcess", :foreign_key => "business_process_id"
    belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
    belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
    has_many :production_schedules, :dependent => :destroy
    has_many :production_executions, inverse_of: :parent, :dependent => :destroy
    has_many :production_groups, inverse_of: :parent, :dependent => :destroy
end
