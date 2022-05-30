class ProductionExecution < ApplicationRecord
  ### validations
  	validates :playground_id, presence: true
    belongs_to :parent, :class_name => "ProductionJob", :foreign_key => "production_job_id"
    belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
    belongs_to :environment, :class_name => "Value", :foreign_key => "environment_id"
    belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
    belongs_to :production_schedule, optional: true
    has_many :production_groups, inverse_of: :production_execution, :dependent => :destroy
end
