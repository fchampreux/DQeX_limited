class Scheduler::ScriptWorker
  include Sidekiq::Worker
  include SchedulerExecutionHelper
  include ParametersHelper
  sidekiq_options queue: :default, tags: ['script'], retry: false

  def perform(schedule_id, message)
    schedule = ProductionSchedule.find(schedule_id)
    if schedule.status.code == "ACTIVE"
      Rails.logger.queues.info "--- Starting schedule - id: #{schedule_id},
                                code: #{schedule.code},
                                queue: #{Sidekiq.options[:queue]},
                                payload: #{message}"
      puts "Sidekiq job start"
      puts schedule_id
      @execution = new_execution_instance(schedule_id, message)
      execute_production_groups @execution
    else
      Rails.logger.queues.info "--- INACTIVE schedule - id: #{schedule_id},
                                code: #{schedule.code},
                                queue: #{Sidekiq.options[:queue]},
                                payload: #{message}"
    end
  end
end
