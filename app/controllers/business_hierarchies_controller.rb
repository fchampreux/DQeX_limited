class BusinessHierarchiesController < ApplicationController
  # Check for active session
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /business_hierarchies
  # GET /business_hierarchies.json
  def index
    @business_hierarchies = BusinessHierarchy.order("pcf_reference")#.limit(20)
    @lignes = BusinessHierarchy.count
    @target_playground_id = @business_hierarchies.first.playground_id

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: BusinessHierarchy.order("hierarchy") }
      format.xlsx # uses specific template to render xml
    end
  end

  # Select the playground to generate the business hierarchy, then calls unload
  def new
  end

  # Loads each element of the business hierarchy into dqm application objects
  def load
    # Setup counters
    @lignes = BusinessHierarchy.count
    @counter = [] #object, tries, inserts

    # Read statuses Ids
    new_status = Parameter.joins(:parent).where("parameters_lists.code = ? and parameters.code = ?", 'LIST_OF_STATUSES','NEW').take!
    audit_status = Parameter.joins(:parent).where("parameters_lists.code = ? and parameters.code = ?", 'LIST_OF_BREACH_TYPES','INIT').take!

    # Load Business areas
    monitor = {:object => 'Business Areas', :tries => 0, :inserts => 0}
    business_areas_list = BusinessHierarchy.where("hierarchical_level = 1").order("hierarchy")
    business_areas_list.each do |ba|
      @business_area = BusinessArea.new
      @business_area.playground_id = params[:target_playground_id]
      @business_area.code = ba.pcf_reference.gsub('.00','') # Remove trailing .00 at this level
      @business_area.name = ba.name
      @business_area.description = ba.description
      @business_area.hierarchy = ba.hierarchy # This value is overwritten by before filter un the BA model validations
      @business_area.pcf_index = ba.pcf_index
      @business_area.pcf_reference = ba.pcf_reference
      @business_area.status_id = new_status.id
      @business_area.owner_id = current_user.id
      #@business_area.organisation_id = 0
      @business_area.responsible_id = 0
      @business_area.deputy_id = 0
      @business_area.created_by = current_login
      @business_area.updated_by = current_login
      # create name and description translations
      @business_area.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: ba.name_fr)
      @business_area.name_translations.build(field_name: 'name', language: 'de_OFS', translation: ba.name_de)
      @business_area.name_translations.build(field_name: 'name', language: 'it_OFS', translation: ba.name_it)
      @business_area.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: ba.description_fr)
      @business_area.description_translations.build(field_name: 'description', language: 'de_OFS', translation: ba.description_de)
      @business_area.description_translations.build(field_name: 'description', language: 'it_OFS', translation: ba.description_it)

      # update counters
      monitor[:tries] += 1
      if @business_area.save
        monitor[:inserts] += 1
      else
        #log_activit
      end
    end
    # save counters
    @counter.push(monitor)

    # Load Business Flows
    monitor = {:object => 'Business Flows', :tries => 0, :inserts => 0}
    business_flows_list = BusinessHierarchy.where("hierarchical_level = 2").order("hierarchy")
    business_flows_list.each do |bf|
      if BusinessArea.exists?(:hierarchy => bf.hierarchy.first(-4)) #test if the parent business area exists
      ba=BusinessArea.where("hierarchy = ?", bf.hierarchy.first(-4)).take! #removes the last 4 characters of bf to look for ba.
      @business_flow = BusinessFlow.new
      @business_flow.playground_id = params[:target_playground_id]
      @business_flow.business_area_id = ba.id
      @business_flow.code = bf.pcf_reference.remove(ba.pcf_reference + '.')
      @business_flow.name = bf.name
      @business_flow.description = bf.description
      @business_flow.hierarchy = bf.hierarchy # This value is overwritten by before filter un the BF model validations
      @business_flow.pcf_index = bf.pcf_index
      @business_flow.pcf_reference = bf.pcf_reference
      @business_flow.status_id = new_status.id
      @business_flow.owner_id = current_user.id
      @business_flow.organisation_id = 0
      @business_flow.responsible_id = 0
      @business_flow.deputy_id = 0
      @business_flow.created_by = current_login
      @business_flow.updated_by = current_login
      # create name and description translations
      @business_flow.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: bf.name_fr)
      @business_flow.name_translations.build(field_name: 'name', language: 'de_OFS', translation: bf.name_de)
      @business_flow.name_translations.build(field_name: 'name', language: 'it_OFS', translation: bf.name_it)
      @business_flow.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: bf.description_fr)
      @business_flow.description_translations.build(field_name: 'description', language: 'de_OFS', translation: bf.description_de)
      @business_flow.description_translations.build(field_name: 'description', language: 'it_OFS', translation: bf.description_it)

      # update counters
      monitor[:tries] += 1
      if @business_flow.save
        monitor[:inserts] += 1
      end
      # log errors if any
      if @business_flow.errors.any?
        #log_activity
      end
      else # logs an error if parent business area does not exist
      # update counters
      monitor[:tries] += 1
        #log_activity
      end
    end
    # save counters
    @counter.push(monitor)

    # Load Business Processes
    monitor = {:object => 'Business Processes', :tries => 0, :inserts => 0}
    business_processes_list = BusinessHierarchy.where("hierarchical_level = 3").order("hierarchy")
    business_processes_list.each do |bp|
      if BusinessFlow.exists?(:hierarchy => bp.hierarchy.first(-4)) #test if the parent business flow exists
      bf=BusinessFlow.where("hierarchy = ?", bp.hierarchy.first(-4)).take! #removes the last 4 characters of bf to look for bf.
      @business_process = BusinessProcess.new
      @business_process.playground_id = params[:target_playground_id]
      @business_process.business_flow_id = bf.id
      @business_process.code = bp.pcf_reference.remove(bf.pcf_reference + '.')
      @business_process.name = bp.name
      @business_process.description = bp.description
      @business_process.hierarchy = bp.hierarchy # This value is overwritten by before filter un the BP model validations
      @business_process.pcf_index = bp.pcf_index
      @business_process.pcf_reference = bp.pcf_reference
      @business_process.status_id = new_status.id
      @business_process.owner_id = current_user.id
      @business_process.organisation_id = 0
      @business_process.responsible_id = 0
      @business_process.deputy_id = 0
      @business_process.created_by = current_login
      @business_process.updated_by = current_login
      # create name and description translations
      @business_process.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: bp.name_fr)
      @business_process.name_translations.build(field_name: 'name', language: 'de_OFS', translation: bp.name_de)
      @business_process.name_translations.build(field_name: 'name', language: 'it_OFS', translation: bp.name_it)
      @business_process.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: bp.description_fr)
      @business_process.description_translations.build(field_name: 'description', language: 'de_OFS', translation: bp.description_de)
      @business_process.description_translations.build(field_name: 'description', language: 'it_OFS', translation: bp.description_it)

      # update counters
      monitor[:tries] += 1
      if @business_process.save
        monitor[:inserts] += 1
      end
      # log errors if any
      if @business_process.errors.any?
        #log_activity
      end
      else # logs an error if parent business flow does not exist
      # update counters
      monitor[:tries] += 1
        #log_activity
      end
    end
    # save counters
    @counter.push(monitor)

    # Load Business Activities
      monitor = {:object => 'Activities', :tries => 0, :inserts => 0}
      activities_list = BusinessHierarchy.where("hierarchical_level = 4").order("hierarchy")
      activities_list.each do |activity|
      if BusinessProcess.exists?(:hierarchy => activity.hierarchy.first(-4)) #test if the parent business process exists
      bp=BusinessProcess.where("hierarchy = ?", activity.hierarchy.first(-4)).take! #removes the last 4 characters of bf to look for bp.
      @activity = Activity.new
      @activity.playground_id = params[:target_playground_id]
      @activity.business_process_id = bp.id
      @activity.code = activity.pcf_reference.remove(bp.pcf_reference + '.')
      @activity.name = activity.name
      @activity.description = activity.description
      @activity.hierarchy = activity.hierarchy # This value is overwritten by before filter un the Activity model validations
      @activity.pcf_index = activity.pcf_index
      @activity.pcf_reference = activity.pcf_reference
      @activity.status_id = new_status.id
      @activity.owner_id = current_user.id
      @activity.organisation_id = 0
      @activity.responsible_id = 0
      @activity.deputy_id = 0
      @activity.created_by = current_login
      @activity.updated_by = current_login
      # create name and description translations
      @activity.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: activity.name_fr)
      @activity.name_translations.build(field_name: 'name', language: 'de_OFS', translation: activity.name_de)
      @activity.name_translations.build(field_name: 'name', language: 'it_OFS', translation: activity.name_it)
      @activity.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: activity.description_fr)
      @activity.description_translations.build(field_name: 'description', language: 'de_OFS', translation: activity.description_de)
      @activity.description_translations.build(field_name: 'description', language: 'it_OFS', translation: activity.description_it)

      # update counters
      monitor[:tries] += 1
      if @activity.save
        monitor[:inserts] += 1
      end
      # log errors if any
      if @activity.errors.any?
        #log_activity
      end
      else # logs an error if parent business process does not exist
      # update counters
      monitor[:tries] += 1
        #log_activity
      end
    end
    # save counters
    @counter.push(monitor)

    # Load Tasks
      monitor = {:object => 'Tasks', :tries => 0, :inserts => 0}
      tasks_list = BusinessHierarchy.where("hierarchical_level = 5").order("hierarchy")
      tasks_list.each do |task|
      if Activity.exists?(:hierarchy => task.hierarchy.first(-4)) #test if the parent business process exists
      activity=Activity.where("hierarchy = ?", task.hierarchy.first(-4)).take! #removes the last 4 characters of bf to look for activity.
      @task = Task.new
      @task.playground_id = params[:target_playground_id]
      @task.activity_id = activity.id
      @task.code = task.pcf_reference.remove(activity.pcf_reference + '.')
      @task.name = task.name
      @task.description = task.description
      @task.hierarchy = task.hierarchy # This value is overwritten by before filter un the Activity model validations
      @task.pcf_index = task.pcf_index
      @task.pcf_reference = task.pcf_reference
      @task.status_id = new_status.id
      @task.owner_id = current_user.id
      @task.organisation_id = 0
      @task.responsible_id = 0
      @task.deputy_id = 0
      @task.created_by = current_login
      @task.updated_by = current_login
      # create name and description translations
      @task.name_translations.build(field_name: 'name', language: 'fr_OFS', translation: task.name_fr)
      @task.name_translations.build(field_name: 'name', language: 'de_OFS', translation: task.name_de)
      @task.name_translations.build(field_name: 'name', language: 'it_OFS', translation: task.name_it)
      @task.description_translations.build(field_name: 'description', language: 'fr_OFS', translation: task.description_fr)
      @task.description_translations.build(field_name: 'description', language: 'de_OFS', translation: task.description_de)
      @task.description_translations.build(field_name: 'description', language: 'it_OFS', translation: task.description_it)

      # update counters
      monitor[:tries] += 1
      if @task.save
        monitor[:inserts] += 1
      end
      # log errors if any
      if @task.errors.any?
        #log_activity
      end
      else # logs an error if parent activity does not exist
        # update counters
        monitor[:tries] += 1
          #log_activity
      end
    end
    # save counters
    @counter.push(monitor)

    # finally log the load results
      #log_activity
  end

  def unload
  # Generates a business hierarchy ready to export to a MS Excel file
  # Search for selected playground, then iterate through hierarchy, and exports result to XLSX file
  require 'write_xlsx'
  # Truncate table
  ActiveRecord::Base.connection.execute("TRUNCATE table business_hierarchies")
  # Setup counter
    @counter = [] #object, tries, inserts
    monitor = {:object => 'Business Hierarchies', :tries => 0, :inserts => 0}
    audit_status = Parameter.joins(:parameters_list).where("parameters_lists.code = ? and parameters.code = ?", 'LIST_OF_BREACH_TYPES','INIT').take!

    # == Schema Information
    #
    # Table name: business_hierarchies
    #
    #  id                 :integer          not null, primary key
    #  playground_id      :integer
    #  pcf_index          :string
    #  pcf_reference      :string
    #  hierarchical_level :integer
    #  hierarchy          :string
    #  name               :string
    #  description        :text
    #  created_at         :datetime         not null
    #  updated_at         :datetime         not null
    #
    playground = Playground.find(params[:playground_id]).id

    # Business areas
    @business_areas = BusinessArea.joins(translated_areas).pgnd(playground).current.select(areas_fields).order("hierarchy")
    @business_areas.each do |ba|
      hierarchy = BusinessHierarchy.new
      hierarchy.playground_id = ba.playground_id
      hierarchy.pcf_index = ba.pcf_index
      hierarchy.pcf_reference = ba.pcf_reference
      hierarchy.hierarchical_level = ba.hierarchy.count('.')
      hierarchy.hierarchy = ba.hierarchy
      hierarchy.name = ba.translated_name || 'Missing Translation'
      hierarchy.description = ba.translated_description || 'Missing Translation'

      monitor[:tries] += 1
      if hierarchy.save
        monitor[:inserts] += 1
      else
        #log_activity
      end

    # Business Flows
      @business_flows = BusinessFlow.joins(translated_flows).pgnd(playground).current.where("business_area_id = ?", ba.id).select(flows_fields).order("hierarchy")
      @business_flows.each do |bf|
        hierarchy = BusinessHierarchy.new
        hierarchy.playground_id = bf.playground_id
        hierarchy.pcf_index = bf.pcf_index
        hierarchy.pcf_reference = bf.pcf_reference
        hierarchy.hierarchical_level = bf.hierarchy.count('.')
        hierarchy.hierarchy = bf.hierarchy
        hierarchy.name = bf.translated_name || 'Missing Translation'
        hierarchy.description = bf.translated_description || 'Missing Translation'

        monitor[:tries] += 1
        if hierarchy.save
          monitor[:inserts] += 1
        else
          #log_activity
        end

    # Business Processes
        @business_processes = BusinessProcess.joins(translated_processes).pgnd(playground).current.where("business_flow_id = ?", bf.id).select(processes_fields).order("hierarchy")
        @business_processes.each do |bp|
          hierarchy = BusinessHierarchy.new
          hierarchy.playground_id = bp.playground_id
          hierarchy.pcf_index = bp.pcf_index
          hierarchy.pcf_reference = bp.pcf_reference
          hierarchy.hierarchical_level = bp.hierarchy.count('.')
          hierarchy.hierarchy = bp.hierarchy
          hierarchy.name = bp.translated_name || 'Missing Translation'
          hierarchy.description = bp.translated_description || 'Missing Translation'

          monitor[:tries] += 1
          if hierarchy.save
            monitor[:inserts] += 1
          else
            #log_activity
          end

    # Activities
          @activities = Activity.joins(translated_activities).pgnd(playground).current.where("business_process_id = ?", bp.id).select(activities_fields).order("hierarchy")
          @activities.each do |act|
            hierarchy = BusinessHierarchy.new
            hierarchy.playground_id = act.playground_id
            hierarchy.pcf_index = act.pcf_index
            hierarchy.pcf_reference = act.pcf_reference
            hierarchy.hierarchical_level = act.hierarchy.count('.')
            hierarchy.hierarchy = act.hierarchy
            hierarchy.name = act.translated_name || 'Missing Translation'
            hierarchy.description = act.translated_description || 'Missing Translation'

            monitor[:tries] += 1
            if hierarchy.save
              monitor[:inserts] += 1
            else
              #log_activity
            end

    # Tasks
            @tasks = Task.joins(translated_tasks).pgnd(playground).current.where("activity_id = ?", act.id).select(tasks_fields).order("hierarchy")
            @tasks.each do |task|
              hierarchy = BusinessHierarchy.new
              hierarchy.playground_id = task.playground_id
              hierarchy.pcf_index = task.pcf_index
              hierarchy.pcf_reference = task.pcf_reference
              hierarchy.hierarchical_level = task.hierarchy.count('.')
              hierarchy.hierarchy = task.hierarchy
              hierarchy.name = task.translated_name || 'Missing Translation'
              hierarchy.description = task.translated_description || 'Missing Translation'

              monitor[:tries] += 1
              if hierarchy.save
                monitor[:inserts] += 1
              else
                #log_activity
              end

            end

          end

        end

      end

    end
    @counter.push(monitor)
    @lignes = monitor[:tries]

    ### Export each record to XLSX file formated as APQC's PCF
    # Create a new XLSX workbook
    @workbook = WriteXLSX.new("public/dqmBusinessHierarchy.xlsx")

    # Add a worksheet
    worksheet = @workbook.add_worksheet("Combined")

    # Add and define a format
    header = @workbook.add_format # Add a format
    header.set_bold
    header.set_color('blue')
    header.set_align('center')
    string_cell = @workbook.add_format(:num_format => '@')

    # Fill header
    puts "write header"
    row = 0
    worksheet.write(row, 0, "PCF ID", header)
    worksheet.write(row, 1, "Hierarchy ID", header)
    worksheet.write(row, 2, "Name", header)

    # Fill in rows
    puts "write lines"
    puts BusinessHierarchy.count
    business_hierarchies = BusinessHierarchy.all.order("hierarchy")
    business_hierarchies.each do |bh|
      row += 1
      # Format hierarchy the same way as APQC
      hierarchy = bh.hierarchy[(bh.hierarchy.index('.')+1)..-1] # Remove playground from hierarchy
      built_hierarchy = hierarchy.split('.').map {|index| index.to_i.to_s}.join('.') # Remove leading 0s at each index of hierarchy
      worksheet.write(row, 0, bh.pcf_reference)
      worksheet.write_string(row, 1, built_hierarchy, string_cell)
      worksheet.write(row, 2, bh.name)
      worksheet.write_comment(row, 2, bh.description)
    end

    @workbook.close
  end

### private functions
  private

  ### queries tayloring

  def names
    Translation.arel_table.alias('tr_names')
  end

  def descriptions
    Translation.arel_table.alias('tr_descriptions')
  end

  def areas
    BusinessArea.arel_table
  end
  def flows
    BusinessFlow.arel_table
  end
  def processes
    BusinessProcess.arel_table
  end
  def activities
    Activity.arel_table
  end
  def tasks
    Task.arel_table
  end

  def translated_areas
    areas.
    join(names, Arel::Nodes::OuterJoin).on(areas[:id].eq(names[:document_id]).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
    join(descriptions, Arel::Nodes::OuterJoin).on(areas[:id].eq(descriptions[:document_id]).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
    join_sources
  end

  def translated_flows
    flows.
    join(names, Arel::Nodes::OuterJoin).on(flows[:id].eq(names[:document_id]).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
    join(descriptions, Arel::Nodes::OuterJoin).on(flows[:id].eq(descriptions[:document_id]).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
    join_sources
  end

  def translated_processes
    processes.
    join(names, Arel::Nodes::OuterJoin).on(processes[:id].eq(names[:document_id]).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
    join(descriptions, Arel::Nodes::OuterJoin).on(processes[:id].eq(descriptions[:document_id]).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
    join_sources
  end

  def translated_activities
    activities.
    join(names, Arel::Nodes::OuterJoin).on(activities[:id].eq(names[:document_id]).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
    join(descriptions, Arel::Nodes::OuterJoin).on(activities[:id].eq(descriptions[:document_id]).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
    join_sources
  end

  def translated_tasks
    tasks.
    join(names, Arel::Nodes::OuterJoin).on(tasks[:id].eq(names[:document_id]).and(names[:language].eq(current_language).and(names[:field_name].eq('name')))).
    join(descriptions, Arel::Nodes::OuterJoin).on(tasks[:id].eq(descriptions[:document_id]).and(descriptions[:language].eq(current_language).and(descriptions[:field_name].eq('description')))).
    join_sources
  end

  def areas_fields
    [areas[:id], areas[:code], areas[:hierarchy], areas[:name], areas[:description], areas[:status_id], areas[:updated_by], areas[:updated_at], areas[:pcf_index], areas[:playground_id], areas[:pcf_reference],
     names[:translation].as("translated_name"),
     descriptions[:translation].as("translated_description")]
  end

  def flows_fields
    [flows[:id], flows[:code], flows[:hierarchy], flows[:name], flows[:description], flows[:status_id], flows[:updated_by], flows[:updated_at], flows[:pcf_index], flows[:playground_id], flows[:pcf_reference],
     names[:translation].as("translated_name"),
     descriptions[:translation].as("translated_description")]
  end

  def processes_fields
    [processes[:id], processes[:code], processes[:hierarchy], processes[:name], processes[:description], processes[:status_id], processes[:updated_by], processes[:updated_at], processes[:pcf_index], processes[:playground_id], processes[:pcf_reference],
     names[:translation].as("translated_name"),
     descriptions[:translation].as("translated_description")]
  end

  def activities_fields
    [activities[:id], activities[:code], activities[:hierarchy], activities[:name], activities[:description], activities[:status_id], activities[:updated_by], activities[:updated_at], activities[:pcf_index], activities[:playground_id], activities[:pcf_reference],
     names[:translation].as("translated_name"),
     descriptions[:translation].as("translated_description")]
  end

  def tasks_fields
    [tasks[:id], tasks[:code], tasks[:hierarchy], tasks[:name], tasks[:description], tasks[:status_id], tasks[:updated_by], tasks[:updated_at], tasks[:pcf_index], tasks[:playground_id], tasks[:pcf_reference],
     names[:translation].as("translated_name"),
     descriptions[:translation].as("translated_description")]
  end

  ### strong parameters
  def business_hierarchy_params
    params.require(:business_hierarchy).permit(:target_playground_id, :target_language)
  end

end
