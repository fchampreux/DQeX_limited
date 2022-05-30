module SchedulerExecutionHelper
  include ParametersHelper
  include AnnotationsHelper

  def status_icons
    { "READY": { "icon": "fa fa-clipboard-check status-active", "title": t('Ready') },
      "RUNNING": { "icon": "fa fa-fast-forward", "title": t('Running') },
      "FINISHED": { "icon": "fa fa-thumbs-up success", "title": t('Finished') },
      "WARNING": { "icon": "fa fa-exclamation warning" },
      "STALL": { "icon": "fa fa-ban failed", "title": t('Stall') },
      "NEW": { "icon": "fa fa-glasses status-pending", "title": t('New') }
    }
  end

  def get_connection_string(connection_id)
    remote_system = Value.find(connection_id)
    remote_host = remote_system&.uri
    remote_login = remote_system.annotations.where(code: 'LOGIN').take # Both ways of doing it work fine.
    remote_user = remote_login&.name
    remote_password = remote_login&.uri
    Rails.logger.ssh.info "--- connection string: #{remote_user}@#{remote_host}"
    connection = { uri: remote_host, login: remote_user, password: remote_password }
  end

  # Generate production job instance according to schedule
  def new_execution_instance(schedule_id, *message)
    ### How it works
    # A job schedule creates an execution instance each time it is invoked
    # The execution instance is a duplicate of job's groups and events
    # The schedule's paramters are a copy of job's parameter, but can be modified by the user at scheduling
    # Thus, schedule's parameters will overwrite execution's parameters, but not (yet) at group nor event level.
    # The test_mode is a flag to allow an interactive and editable execution. Pass true flag for 'test' execution.
    @production_schedule = ProductionSchedule.find(schedule_id)
    Rails.logger.queues.info "--- Create execution instance - id: #{schedule_id},
                              code: #{@production_schedule.code},
                              queue: #{@production_schedule.queue_key},
                              payload: #{message[0]}"

    if message[0]
      # Format the message as a JSON parameter
      formatted_message = {
        "name": @production_schedule.message_identifier || 'No message identifier',
        "dataType": "STRING",
        "value": message[0][@production_schedule.message_identifier],
        "isMandatory": "true"
      }
    end
    # Create the execution instance based on the schedule
    @production_schedule.update_attribute(:last_run, Time.now)
    @production_job = @production_schedule.parent
    @execution_instance = @production_job.production_executions
                                         .build(playground_id: @production_job.playground_id,
                                                production_job_id: @production_job.id,
                                                code: @production_schedule.code,
                                                environment_id: @production_schedule.environment_id,
                                                owner_id: @production_schedule.owner_id,
                                                status_id: statuses.find { |x| x['code'] == 'READY' }.id,
                                                is_for_test: @production_schedule.mode.code == 'TEST',
                                                parameters: @production_schedule.parameters,
                                                message_id: message[0] ? message[0][@production_schedule.message_identifier] : nil
                                               )
    if message[0]
      # Add or update the message identifier parameter
      if @execution_instance.parameters.find{|hash| hash["name"] == @production_schedule.message_identifier}
        @execution_instance.parameters.find{|hash| hash["name"] == @production_schedule.message_identifier}["value"] = message[0][@production_schedule.message_identifier]
      else
        @execution_instance.parameters << JSON.parse(formatted_message.to_json) # Add the message identifier parameter to the list
      end
    end
    Rails.logger.queues.info "    --- instance parameters: #{@execution_instance.parameters}"
    # Duplicate each production group and production event into the new instance
    if @execution_instance.save
      @production_job.production_groups.where(production_execution_id: nil).each do |group|
        execution_group = group.dup
        execution_group.predecessor_id = group.id # save the former id for later matching
        execution_group.production_execution_id = @execution_instance.id
        if message[0]
          # Add or update the message identifier parameter
          if execution_group.parameters.find{|hash| hash["name"] == @production_schedule.message_identifier}
            execution_group.parameters.find{|hash| hash["name"] == @production_schedule.message_identifier}["value"] = message[0][@production_schedule.message_identifier]
          else
            execution_group.parameters << JSON.parse(formatted_message.to_json) # Add the message identifier parameter to the list
          end
        end
        Rails.logger.queues.info "    --- group parameters: #{execution_group.parameters}"
        execution_group.status_id = statuses.find { |x| x["code"] == "READY" }.id
        execution_group.error_message = nil
        execution_group.source_records_count = 0
        execution_group.processed_count = 0
        execution_group.created_count = 0
        execution_group.read_count = 0
        execution_group.updated_count = 0
        execution_group.deleted_count = 0
        execution_group.rejected_count = 0
        execution_group.error_count = 0
        # Duplicate each production event into the new instance
        if execution_group.save
          group.production_events.where(production_execution_id: nil).each do |event|
            execution_event = event.dup
            execution_event.predecessor_id = event.id # save the former id for later matching
            execution_event.production_group_id = execution_group.id
            execution_event.production_execution_id = @execution_instance.id
            if message[0]
              # Add or update the message identifier parameter
              if execution_event.parameters.find{|hash| hash["name"] == @production_schedule.message_identifier}
                execution_event.parameters.find{|hash| hash["name"] == @production_schedule.message_identifier}["value"] = message[0][@production_schedule.message_identifier]
              else
                execution_event.parameters << JSON.parse(formatted_message.to_json) # Add the message identifier parameter to the list
              end
            end
            Rails.logger.queues.info "    --- group parameters: #{execution_event.parameters}"
            execution_event.status_id = statuses.find { |x| x["code"] == "READY" }.id
            execution_event.return_value = 0
            execution_event.error_message = nil
            execution_event.completion_message = nil
            execution_event.source_records_count = 0
            execution_event.processed_count = 0
            execution_event.created_count = 0
            execution_event.read_count = 0
            execution_event.updated_count = 0
            execution_event.deleted_count = 0
            execution_event.rejected_count = 0
            execution_event.error_count = 0
            execution_event.save
          end
        end
      end
      # After duplication, reassign new success and failure links
      @execution_instance.production_groups.each do |group|
        # Search for the success_next_id group based on its former id (before duplication) within the same instance
        if group.success_next_id
          group.success_next_id = ProductionGroup.where(predecessor_id: group.success_next_id,
                                                        production_execution_id: @execution_instance.id)
                                                 .take&.id
        end
        if group.failure_next_id
          group.failure_next_id = ProductionGroup.where(predecessor_id: group.failure_next_id,
                                                        production_execution_id: @execution_instance.id)
                                                 .take&.id
        end
        group.save
        group.production_events.each do |event|
          # Search for the success_next_id event based on its former id (before duplication) within the same group
          if event.success_next_id
            event.success_next_id = ProductionEvent.where(predecessor_id: event.success_next_id,
                                                          production_group_id: group.id)
                                                   .take&.id
          end
          if event.failure_next_id
            event.failure_next_id = ProductionEvent.where(predecessor_id: event.failure_next_id,
                                                          production_group_id: group.id)
                                                   .take&.id
          end
          # Uniquely identify the event for traceability of requests
          event.request_id = "#{@execution_instance.id}/#{group.id}-#{event.id}"
          event.save
        end
      end
    end
    @execution_instance
  end

  ### Executes the list of production groups belonging to the production execution
  def execute_production_groups(execution)
    execution.update_attributes(started_at: Time.now,
                                status_id: statuses.find { |x| x["code"] == "RUNNING" }.id)

    ProductionGroup.where(production_execution_id: execution.id)
                   .update_all(started_at: nil,
                               ended_at: nil,
                               status_id: statuses.find { |x| x["code"] == "READY" }.id,
                               execution_sequence: 999,
                               predecessor_id: nil)

    # Reset status and variables
    input_count = 0
    output_count = 0
    error_count = 0
    sequence = 1
    output = ''
    log_message = ''

    ### Execute events based on the "next if" links
    Rails.logger.ssh.info "### ### || -- Run #{execution.parent.code} job || ### ###"
    Rails.logger.ssh.info '---     || Start iterating through groups ||          ---'

    # Find the first group to execute
    first_group = execution.production_groups
                           .where(node_type_id: parameters_for('node_types', 'Scheduler')
                                                .find { |x| x["code"] == "START" }
                                                .id
                                  )
                           .first
    last_group = execution.production_groups
                          .where(node_type_id: parameters_for('node_types', 'Scheduler')
                                               .find { |x| x["code"] == "END" }
                                               .id
                                 )
                          .first
    rescue_group = execution.production_groups
                            .where(node_type_id: parameters_for('node_types', 'Scheduler')
                                                 .find { |x| x["code"] == "RESCUE" }
                                                 .id
                                   )
                            .first

    predecessor_group = ProductionGroup.new
    next_group = first_group

    # Loop over groups until meeting an END or RESCUE group
    begin
      group = next_group
      Rails.logger.ssh.info "--- --- group: #{group.node_type.code}/ #{group.activity.code} --- ---"
      if group.production_events.any?
        group_status = execute_group_events(group, predecessor_group, ProductionEvent.new, sequence)
      else
        group.update_attributes(started_at: Time.now,
                                ended_at: Time.now,
                                predecessor_id: predecessor_group.id,
                                status_id: statuses.find { |x| x["code"] == "FINISHED" }.id,
                                execution_sequence: sequence)
      end
      sequence += 1

      # Search for the next group to execute
      if group.status.code == 'STALL'
        next_group = rescue_group
      else
        next_group = group.success_next
      end

      # Push up group statuses, except for End or Rescue group which are not significant
      unless group.node_type.code == 'END' || group.node_type.code == 'RESCUE'
        output = group_status ? 'Success' : 'Failure'
        log_message = group.error_message
        input_count += group.source_records_count
        output_count += group.processed_count
        error_count += group.error_count
        predecessor_group = group
        # Assign the event's output_contract values to execution parameters
        group.parameters.each do |response|
          if execution.parameters.find {|param| param["name"] == response["name"]}
            execution.parameters.find {|param| param["name"] == response["name"]}["value"] = response["value"]
          else
            execution.parameters << response # Add the unexpected parameter to the list
          end
          # Show the result
          Rails.logger.ssh.info "      #{ response["name"]
                                    }: #{ execution.parameters.find {|param| param["name"] == response["name"]}["value"]
                                    }"
        end

        # Update log while running
        Rails.logger.ssh.info "--- --- group status: #{group.status.code} - jump to #{next_group.node_type.code if next_group}/ #{next_group.activity.code if next_group} --- ---"
        execution.reported_at = Time.now
        execution.save
      end

    # Exit when reaching the End or Rescue group
    end until group.node_type.code == 'END' || group.node_type.code == 'RESCUE'

    Rails.logger.ssh.info "--- || Ended executing groups || ---"

    execution.update_attributes(ended_at: Time.now,
                                status_id: predecessor_group.status_id || 1,
                                source_records_count: input_count,
                                processed_count: output_count,
                                error_message: log_message
                                )
  end

  ### Executes the list of production events belonging to the production group
  # The production_event parameter is the production event to start from
  # when a rescue is in progress
  def execute_group_events(group, predecessor_group, production_event, group_sequence)
  # TO DO ### Check Git Hash if any
    group.update_attributes(started_at: Time.now,
                            predecessor_id: predecessor_group.id,
                            status_id: statuses.find { |x| x["code"] == "RUNNING" }.id,
                            execution_sequence: group_sequence
                            )

    # Reset status and variables but if a rescue is in progress
    if production_event.execution_sequence.zero? # Production event is not defined
      ProductionEvent.where(production_group_id: group.id)
                     .update_all(started_at: nil,
                                 ended_at: nil,
                                 status_id: statuses.find { |x| x["code"] == "READY" }.id,
                                 execution_sequence: 999,
                                 predecessor_id: nil
                                 )
      input_count = 0
      output_count = 0
      error_count = 0
      sequence = 1
    else
      input_count = production_event.source_records_count
      output_count = production_event.processed_count
      error_count = production_event.error_count
      sequence = production_event.execution_sequence + 2
    end
    output = ''
    log_message = ''


    ### Execute events based on the "next if" links
    Rails.logger.ssh.info "--- || -- Run #{group.activity.code} group || ---"
    Rails.logger.ssh.info '--- || Start iterating through events || ---'
    # Find the first event to execute
    first_event = group.production_events
                        .where(node_type_id: parameters_for('node_types', 'Scheduler')
                                            .find { |x| x["code"] == "START" }
                                            .id
                              )
                        .first
    last_event = group.production_events
                      .where(node_type_id: parameters_for('node_types', 'Scheduler')
                                          .find { |x| x["code"] == "END" }
                                          .id
                            )
                      .first
    rescue_event = group.production_events
                        .where(node_type_id: parameters_for('node_types', 'Scheduler')
                                            .find { |x| x["code"] == "RESCUE" }
                                            .id
                              )
                        .first
    predecessor_event = ProductionEvent.new

    if production_event.execution_sequence.zero? # Production event parameter is not defined
      next_event = first_event
    else # Start from recovered event
      next_event = production_event
    end

    # Loop over events until meeting an END or RESCUE event
    begin
      event = next_event
      Rails.logger.ssh.info "--- --- Invoking event: #{event.node_type.code}/ #{event.task.code} --- ---"

      event_status = execute_ssh(event, predecessor_event, sequence)
      sequence += 1

      # Search for the next event to execute
      if event.status.code == 'STALL'
        next_event = rescue_event
      else
        next_event = event.success_next
      end

      # Push up event statuses, except for End or Rescue event which are not significant
      unless event.node_type.code == 'END' || event.node_type.code == 'RESCUE'
        output = event.return_value
        log_message = event.error_message
        input_count += event.source_records_count
        output_count += event.processed_count
        error_count += event.error_count
        predecessor_event = event
        # Assign the event's output_contract values to group parameters
        Rails.logger.ssh.info '      Assign contract output parameters to group:'
        event.parameters.each do |response|
          if group.parameters.find {|param| param["name"] == response["name"]}
            group.parameters.find {|param| param["name"] == response["name"]}["value"] = response["value"]
          else
            group.parameters << response # Add the unexpected parameter to the list
          end
          # Show the result
          Rails.logger.ssh.info "      #{ response["name"]
                                    }: #{ group.parameters.find {|param| param["name"] == response["name"]}["value"]
                                    }"
        end

        # Update log while running
        Rails.logger.ssh.info "--- --- event status: #{event.status.code} - jump to #{next_event.node_type.code}/ #{next_event.task.code} --- ---"
        group.reported_at = Time.now
        group.save
      else
        # If an error occured before, modify the status of current END or RESCUE event
        if predecessor_event.status.code == 'STALL'
          event.update_attributes(status_id: statuses.find { |x| x["code"] == "STALL" }.id,
                                  error_message: "An unrecoverable error has occurred")
        end
      end

    # Exit when reaching the End or Rescue event
    end until event.node_type.code == 'END' || event.node_type.code == 'RESCUE'

    Rails.logger.ssh.info "--- || Ended executing events || ---"

    group.update_attributes(ended_at: Time.now,
                            status_id: predecessor_event.status_id || 1,
                            source_records_count: input_count,
                            processed_count: output_count,
                            error_message: log_message
                            )
  end

  def execute_ssh(event, predecessor_event, sequence)
    Rails.logger.ssh.info "--- Start SSH execution: #{event.code}"
    event.update_attributes(started_at: Time.now,
                            predecessor_id: predecessor_event&.id,
                            status_id: statuses.find { |x| x["code"] == "RUNNING" }.id,
                            execution_sequence: sequence)
    # Initialise connection
    connection_hash = get_connection_string(event.technology_id)
    output = '' # Handle SSH response
    is_contract_output = false
    if connection_hash[:uri].blank? ||
       connection_hash[:login].blank? ||
       connection_hash[:password].blank? ||
       event.statement.blank?
      event.update_attributes(ended_at: Time.now,
                              status_id: statuses.find { |x| x["code"] == "FINISHED" }.id)
      Rails.logger.ssh.info '--- No SSH connection or missing credentials, skip the step'
    else
      # Execute the statement
      if event.statement.blank?
        output = 'Status=0 - No statement for this task'
      else
        # Generate contract input file
        business_process = event.parent.parent.parent
        contract_input = {
          "statisticalActivityIdentifier": business_process.parent.code,
          "applicationIdentifier": $AppName,
          "storageIdentifier": business_process.zone_to&.code,
          "requestDSDs": [
            { "targerDSDidentifier": event.target_object&.code
            }
          ],
          "userIdentifier": $AppName,
          "requestIP": Rails.application.credentials.integration[:web_server],
          "requestScript": event.parameters.find{|hash| hash["name"] == "script_name"}["value"],
          "requestScriptVersion": event.git_hash,
          "requestObjectId": event.production_execution&.message_id,
          "requestParameters": event.parameters,
          "requestID": event.request_id,
          "scheduledFlowRunId": event.production_execution_id,
          "processMaxDuration": 0
        }
        File.open('tmp/contract_input.json', 'w') do |f|
          f.write(contract_input.to_json)
        end
        # Save the input contract
        event.update_attribute(:contract_input, contract_input)
        Rails.logger.ssh.info '    Saved input contract file at tmp/contract_input.json'

        # Upload the contract input file
        if event.parameters.find {|param| param["name"] == 'log_file_path'}
          contract_file_path = event.parameters.find {|param| param["name"] == 'log_file_path'}["value"]
          contract_file_name = 'contract_input.json'
          copy_success = ssh_file_copy('upload', contract_file_path, contract_file_name, connection_hash)
          if copy_success
            Rails.logger.ssh.info '      Contract input uploaded'
           else
            Rails.logger.ssh.info '      Unable to upload the contract output'
          end
        end

        # Run the remote script
        Rails.logger.ssh.info "    Execute statement via ssh #{connection_hash[:login]}@#{connection_hash[:uri]}"
        begin
          Net::SSH.start(connection_hash[:uri], connection_hash[:login], password: connection_hash[:password]) do |session|
            if event.parameters.find {|param| param["name"] == 'log_file_path'}
              remove_statement = "rm #{event.parameters.find {|param| param["name"] == 'log_file_path'}["value"]}/contract_output.json"
                Rails.logger.ssh.info "      Remove existing contract_output file: #{remove_statement}"
              session.exec! remove_statement
            end
            Rails.logger.ssh.info "      Post statement: #{event.statement}"
            output = session.exec! "#{event.statement} || echo $?"
            Rails.logger.ssh.info '      Close SSH connection'
            session.close
          end
        rescue
          Rails.logger.ssh.info '      Unable to execute the statement via ssh'
          output = 'Status=2 SSH execution error'
        end
        Rails.logger.ssh.info "      SSH output: #{output}"

        # Download the contract output file
        if event.parameters.find {|param| param["name"] == 'log_file_path'}
          contract_file_path = event.parameters.find {|param| param["name"] == 'log_file_path'}["value"]
          contract_file_name = 'contract_output.json'
          copy_success = ssh_file_copy('download', contract_file_path, contract_file_name, connection_hash)
          # Save contract output for traceability
          if copy_success
            is_contract_output = true
            contract_output = JSON.parse(File.read("tmp/contract_output.json"))
            event.update_attribute(:contract_output, contract_output)
            Rails.logger.ssh.info '      Contract output saved'
          else
            Rails.logger.ssh.info '      Unable to save the contract output'
          end
        end
      end

      ### Note : This could be an element of the files list in the contract output
      # Download the log file if any
      if event.parameters.find {|param| param["name"] == 'log_file_path'}
        log_file_path = event.parameters.find {|param| param["name"] == 'log_file_path'}["value"]
        log_file_name = event.parameters.find {|param| param["name"] == 'log_file_name'}["value"]
        copy_success = ssh_file_copy('download', log_file_path, log_file_name, connection_hash)
        # Attach the file to the event for later visualisation
        if copy_success
          attach = event.log_file.attach(io: File.open("tmp/#{log_file_name}"),
                                        filename: log_file_name,
                                        content_type: "text/html")
          Rails.logger.ssh.info '      Log file saved'
        else
          Rails.logger.ssh.info '      Unable to save the log file'
        end
      end
      Rails.logger.ssh.info "    SSH output: #{output}"

      ## Interpreting the contract output
      # Read the first figure from the output
      # The basic codes returned by applications through SSH are:
      # 0 - finished
      # 1 - warning
      # 2 or else - stall
      if is_contract_output
        event.update_attributes(return_value: output.scan(/\d+/)[0],
                                completion_message: output.gsub("\n", ". ").chomp,
                                error_message: event.contract_output["firstErrorMessage"],
                                status_id: (statuses.find { |x| x["property"] == event.contract_output["requestStatus"] } ||
                                            statuses.find { |x| x["code"] == 'STALL'})
                                            .id,
                                source_records_count: event.contract_output["responseTargets"].map{|target| target["sourceRead"].to_i}.sum,
                                processed_count: event.contract_output["responseTargets"].map{|target| target["targetRead"].to_i}.sum,
                                created_count: event.contract_output["responseTargets"].map{|target| target["targetCreate"].to_i}.sum,
                                read_count: event.contract_output["responseTargets"].map{|target| target["targetRead"].to_i}.sum,
                                updated_count: event.contract_output["responseTargets"].map{|target| target["targetUpdate"].to_i}.sum,
                                deleted_count: event.contract_output["responseTargets"].map{|target| target["target_Delete"].to_i}.sum,
                                ended_at: Time.now)
        @msg = 'ExecutionDone'

        ## Updating the parameters with the contract output values
        Rails.logger.ssh.info '      Assign contract output parameters to event:'
        event.contract_output["responseParameters"].each do |response|
          if event.parameters.find {|param| param["name"] == response["key"]}
            event.parameters.find {|param| param["name"] == response["key"]}["value"] = response["value"]
          else
            formatted_response = {
              "name": response["key"],
              "dataType": "STRING",
              "value": response["value"],
              "isMandatory": "true"
            }
            event.parameters << JSON.parse(formatted_response.to_json) # Add the unexpected parameter to the list
          end
          # Show the result
          Rails.logger.ssh.info "      #{ response["key"]
                                    }: #{ event.parameters.find {|param| param["name"] == response["key"]}["value"]
                                    }"
        end

        ## Dowloading files listed in the contract output
        event.contract_output["responseAttachements"].each do |file|
          copy_success = ssh_file_copy('download', file["filePath"], file["fileName"], connection_hash)
          # Attach the file to the event for later visualisation
          if copy_success
            attach = event.attachments.attach(io: File.open("tmp/#{file["fileName"]}"),
                                              filename: file["fileName"],
                                              content_type: "text/html")
            Rails.logger.ssh.info '      Attached file saved'
          else
            Rails.logger.ssh.info "      Unable to attach the file tmp/#{file["fileName"]}"
          end
        end
      else
        # Probably an error, relie on return code to guess the status
        Rails.logger.ssh.info "    No response contract found"
        event.return_value = output.scan(/\d+/)[0] || "2"
        case event.return_value
        when "0"
          event.status_id = statuses.find { |x| x["code"] == 'FINISHED'}.id
          event.completion_message = "OK - #{output.gsub("\n", ". ").chomp}"
          event.error_message = nil
        when "1"
          event.status_id = statuses.find { |x| x["code"] == 'WARNING'}.id
          event.error_message = output.gsub("\n", ". ").chomp
          event.completion_message = output.gsub("\n", ". ").chomp
        else
          event.status_id = statuses.find { |x| x["code"] == 'STALL'}.id
          event.error_message = output.gsub("\n", ". ").chomp
          event.completion_message = nil
        end
      end
      event.save
      Rails.logger.ssh.info "--- SSH end connection. Result: #{event.code} -> #{event.return_value}"
    end
  end

  def ssh_file_copy(direction, file_path, file_name, connection_hash)
    Rails.logger.ssh.info "    --- SCP request: #{connection_hash[:login]}@#{connection_hash[:uri]}"
    Rails.logger.ssh.info "                     #{direction}"
    Rails.logger.ssh.info "                     #{file_path}/#{file_name}"
    unless file_path.blank? || file_name.blank? || connection_hash.blank? || direction.blank?
      begin
        case direction
        when 'download'
          status = Net::SCP.download!(connection_hash[:uri],
                                      connection_hash[:login],
                                      "#{file_path}/#{file_name}",
                                      "tmp/#{file_name}",
                                      :ssh => { password: connection_hash[:password] }
                                      )
          Rails.logger.ssh.info "        SCP request downloaded #{file_path}/#{file_name} to tmp/#{file_name}"
        when 'upload'
          status = Net::SCP.upload!(connection_hash[:uri],
                                    connection_hash[:login],
                                    "tmp/#{file_name}",
                                    "#{file_path}/#{file_name}",
                                    :ssh => { :password => connection_hash[:password] }
                                    )
          Rails.logger.ssh.info "        SCP request uploaded tmp/#{file_name} to #{file_path}/#{file_name} "
        else
          status = false
          Rails.logger.ssh.info "        SCP request does not define the direction: #{direction}"
        end
      rescue
        status = false
        Rails.logger.ssh.info "        SCP unable to connect via #{connection_hash[:login]}@#{connection_hash[:uri]}"
      end
    else
      status = false
      Rails.logger.ssh.info '       SCP request does not accept any blank parameter'
    end
    Rails.logger.ssh.info "    --- SCP #{direction} request closed"
    status
  end

end
