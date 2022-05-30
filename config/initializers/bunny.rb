# Bunny, a RabbitMQ client
=begin
rabbitMQ_client = Bunny.new(Rails.application.credentials.integration[:rabbitMQ_uri])
rabbitMQ_client.start
$rabbitMQ_channel = rabbitMQ_client.create_channel
# $rabbitMQ_exchange = $rabbitMQ_channel.topic(Rails.application.credentials.integration[:exchange], durable: true) # Exists remotely
Rails.logger.queues.info "Started RabbitMQ client: #{rabbitMQ_client}"
Rails.logger.queues.info "Opened RabbitMQ channel: #{$rabbitMQ_channel}"
#Rails.logger.queues.info "Defined RabbitMQ exchange: #{$rabbitMQ_exchange}"
=end
  ### Usage
# queue = $rabbitMQ_channel.queue("Sis-Mediator.WorkflowEnd", :auto_delete => true)
# queue.subscribe do |delivery_info, metadata, payload|
#  puts "Received #{payload}"
# end
# $rabbitMQ_exchange.publish("Hello!", :routing_key => q.name)
