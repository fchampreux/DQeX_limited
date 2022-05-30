module ScopesHelper

  def list_of_business_objects(current_object)
    business_objects_list=DefinedObject.where("scope_id = ?", current_object.id)
  end

end
