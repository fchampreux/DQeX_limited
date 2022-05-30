module BusinessProcessesHelper

  def propagate_parameters_update(business_process)
    business_process.activities.each do |activity|
      activity.update_column(:parameters, business_process.parameters)
      Task.where(parent_id: activity.id, parent_type: "Activity").update_all(parameters: business_process.parameters)
    end
  end

end
