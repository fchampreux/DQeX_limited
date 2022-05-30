module ControllersHelper

  ### initialise object metadata
  def metadata_setup(current_object)
    current_object.updated_by = current_login
    current_object.created_by = current_login
    current_object.playground_id = current_playground
    current_object.owner_id = current_user.id
  end

  def json_parameters_serialization(current_object)
    if params[:parameters]
      puts "--------------- Parameters -----------------"
      puts params[:parameters]
      puts "--- Enumeration"
      puts params[:parameters].to_enum.to_h.to_a.map {|row| row[1]}
      current_object.parameters = params[:parameters].to_enum.to_h.to_a.map {|row| row[1]}
      puts "--- BP value"
      puts current_object.parameters
    else
      current_object.parameters = nil
    end

  end

end
