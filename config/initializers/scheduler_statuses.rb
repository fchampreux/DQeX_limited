# At server boot, ACTIVE Schedules are reset to READY status
# Then the production planning job checks every minute for READY Schedules to activate
# Thus READY schedules are activated only once.
include ParametersHelper
statuses = parameters_for('Statuses')
readyStatusId = statuses.find { |x| x["code"] == "READY" } ? statuses.find { |x| x["code"] == "READY" }.id : 0
activeStatusId = statuses.find { |x| x["code"] == "ACTIVE" } ? statuses.find { |x| x["code"] == "ACTIVE" }.id : 0
ProductionSchedule.where(status_id: activeStatusId).update_all(status_id: readyStatusId)
Rails.logger.queues.info "--- Reset Scheduled Jobs Statuses at SYSTEM STARTUP ---"
Rails.logger.interactions.info "--- Reset Scheduled Jobs Statuses at SYSTEM STARTUP ---"
Rails.logger.info "--- Reset Scheduled Jobs Statuses at SYSTEM STARTUP ---"
