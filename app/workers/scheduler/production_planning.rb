class Scheduler::ProductionPlanning
  include Sidekiq::Worker
  include ParametersHelper

  def perform()
    Rails.logger.queues.info "--- Starting planning scan"
    # At server boot, ACTIVE Schedules are reset to READY status
    # After Schedule update, the Schedule status is set to READY
    # This process runs every minute
    statuses = parameters_for('Statuses')
    schedule_modes = parameters_for('Schedule_modes')
    readyStatusId = statuses.find { |x| x["code"] == "READY" }.id
    activeStatusId = statuses.find { |x| x["code"] == "ACTIVE" }.id
    inActiveStatusId = statuses.find { |x| x["code"] == "INACTIVE" }.id
    messageSchedulingModeId = schedule_modes.find { |x| x["code"] == "MESSAGE" }.id
    testSchedulingModeId = schedule_modes.find { |x| x["code"] == "TEST" }.id

    # 0 - Inactivate schedules out of date
    puts "--- --- Inactivate out-of-date schedules"
    Rails.logger.queues.info "--- --- Inactivate out-of-date schedules"
    count = ProductionSchedule.where.not('? between active_from and active_to', Time.now)
                              .where.not(status_id: inActiveStatusId)
                              .update_all(status_id: inActiveStatusId)

    Rails.logger.queues.info "--- --- Inactivated #{count}"
    puts "--- --- Inactivated #{count}"

    # 1 - Register READY Schedules of type Message to their respective queue
    puts "--- --- Planning Message schedules"
    channel_status = $rabbitMQ_channel.confirm_select
    Rails.logger.queues.info "    --- Check channel: #{channel_status}"
    puts "    --- Check channel: #{channel_status}"

    Rails.logger.queues.info "--- --- Planning Message schedules"
    puts "--- --- Planning Message schedules"
    ProductionSchedule.where(status_id: readyStatusId, mode_id: messageSchedulingModeId).each do |production_schedule|
      puts "        --- Schedule Code: #{production_schedule.code}"
      Rails.logger.queues.info "        --- Schedule Code: #{production_schedule.code}"
      Rails.logger.queues.info "        --- Schedule details: #{production_schedule.queue_exchange}
                                                              #{production_schedule.queue_name}
                                                              #{production_schedule.queue_key}"
      # Create or update the queue
      queue = $rabbitMQ_channel.
              queue(production_schedule.queue_name, auto_delete: true).
              bind(production_schedule.queue_exchange, routing_key: production_schedule.queue_key)
      Rails.logger.queues.info "        --- Message queue: #{queue}"
      puts "        --- Message queue: #{queue}"

      production_schedule.update_attribute(:status_id, activeStatusId)
      Rails.logger.queues.info "        --- Schedule status: #{production_schedule.status.code}"
      puts "        --- Schedule status: #{production_schedule.status.code}"

      # Subscribe to the queue, and start the Sidekiq worker if a message is received
      queue.subscribe do |delivery_info, metadata, payload|
        puts "Received #{payload}"
        # Select the identifier relevant payload part only
        payload_message = JSON.parse(payload).select { |j| j == production_schedule.message_identifier }
        Rails.logger.queues.info "       --- Queue triggered schedule - id: #{production_schedule.id},
                                         code: #{production_schedule.code},
                                         queue: #{production_schedule.queue_key},
                                         payload: #{payload_message}"

        Scheduler::ScriptWorker.perform_async(production_schedule.id, payload_message)
        Rails.logger.queues.info "       --- Schedule: #{production_schedule.code} - #{production_schedule.mode.code} started"
        puts "       --- Schedule: #{production_schedule.code} - #{production_schedule.mode.code} started"
      end
    end

    # 2 - Release other Schedules with the READY status : change to ACTIVE (but the Test schedule)
    Rails.logger.queues.info "    --- Releasing ready schedules"
    puts "    --- Releasing ready schedules"
    counter = ProductionSchedule.where(status_id: readyStatusId)
                                .where.not(mode_id: messageSchedulingModeId)
                                .where.not(mode_id: testSchedulingModeId)
                                .update_all(status_id: activeStatusId)
    Rails.logger.queues.info "--- --- Released #{count}"
    puts "--- --- Released #{count}"

    # 3 - Start ACTIVE Schedules where next run date is older than current date
    Rails.logger.queues.info "    --- Launching active schedules"
    puts "    --- Launching active schedules at #{Time.now}"

    ProductionSchedule.where(status_id: activeStatusId)
                      .where.not(mode_id: messageSchedulingModeId)
                      .where('next_run < current_timestamp')
                      .each do |production_schedule|
      ### Start the asychronous execution
      Scheduler::ScriptWorker.perform_async(production_schedule.id, production_schedule.mode.code)
      Rails.logger.queues.info "       --- Schedule: #{production_schedule.code} - #{production_schedule.mode.code} started"
      puts "       --- Schedule: #{production_schedule.code} - #{production_schedule.mode.code} started"

      # 4 - Calculate next run
      Rails.logger.queues.info "   --- --- Updating the schedule"
      puts "   --- --- Updating the schedule"
      case production_schedule.mode.code
      when "INTERVAL"
        Rails.logger.queues.info "        --- INTERVAL mode"
        puts "        --- INTERVAL mode"
        production_schedule.repeat_counter += 1
        production_schedule.last_run = Time.now.change(sec: 0)
        if production_schedule.repeat_value == production_schedule.repeat_counter and production_schedule.repeat_value != 0
          production_schedule.status_id = inActiveStatusId
          production_schedule.next_run = nil
        else
          case production_schedule.repeat_interval_unit.property
          when 'Minute'
            production_schedule.next_run = production_schedule.last_run + production_schedule.repeat_interval.minute
          when 'Hour'
            production_schedule.next_run = production_schedule.last_run + production_schedule.repeat_interval.hour
          when 'Day'
            production_schedule.next_run = production_schedule.last_run + production_schedule.repeat_interval.day
          when 'Week'
            production_schedule.next_run = production_schedule.last_run + production_schedule.repeat_interval.week
          when 'Month'
            production_schedule.next_run = production_schedule.last_run + production_schedule.repeat_interval.month
          when 'Year'
            production_schedule.next_run = production_schedule.last_run + production_schedule.repeat_interval.year
          end
          Rails.logger.queues.info "        --- Next run #{production_schedule.next_run}"
          puts "        --- Next run #{production_schedule.next_run}"
        end
      when "ON_DATE"
        Rails.logger.queues.info "        --- ON_DATE mode"
        puts "        --- ON_DATE mode"
      else
        Rails.logger.queues.info "--- --- --- Faulty mode, set to inactive"
        puts "--- --- --- Faulty mode, set to inactive"
        production_schedule.status_id = inActiveStatusId
        production_schedule.last_run = nil
      end
      production_schedule.save
    end
  end
end
