class ProductionSchedule < ApplicationRecord
  ### validations    validates :parent,      presence: true
  	validates :playground_id, presence: true
    validate  :event_subscription
    belongs_to :parent, :class_name => "ProductionJob", foreign_key: "production_job_id"
    belongs_to :status, :class_name => "Parameter", :foreign_key => "status_id"	# helps retrieving the status name
    belongs_to :mode,   :class_name => "Parameter", :foreign_key => "mode_id"	# helps retrieving the mode name
    belongs_to :environment, :class_name => "Value", :foreign_key => "environment_id"	# helps retrieving the environment name
    belongs_to :run_on_day,  :class_name => "Parameter", :foreign_key => "run_on_day_id"	# helps retrieving the run day name
    belongs_to :period_type,  :class_name => "Parameter", :foreign_key => "period_type_id"	# helps retrieving the period type
    belongs_to :within_period,  :class_name => "Parameter", :foreign_key => "within_period_id"	# helps retrieving the period name
    belongs_to :repeat_interval_unit,  :class_name => "Parameter", :foreign_key => "repeat_interval_unit_id"	# helps retrieving the time unit name
    belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
    has_many :production_executions


  ### private functions definitions
    private

    def event_subscription
      puts "----- Test that the subscription parameters are correct and unique -----"
      if self.mode.code == "MESSAGE"
        case
        when self.queue_exchange.blank? || self.queue_name.blank? || self.queue_key.blank?
          # Add error to the object's list
          self.errors.add('Subscription to queue', 'is not correctly specified')
        when ProductionSchedule.where(queue_exchange: self.queue_exchange,
                                      queue_key: self.queue_key,
                                      mode_id: parameters_for('schedule_modes').find { |x| x["code"] == "MESSAGE" }.id)
                                .where.not(id: self.id)
                                .exists?
          # Add error to the object's list
          self.errors.add('Subscription to queue', 'is already registered')
        end
      end
      puts self.errors.map {|error, message| [error, message]}.join(', ')
    end
end
