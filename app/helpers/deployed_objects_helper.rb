module DeployedObjectsHelper

  def list_of_scopes(current_object)
    scopes_list=Scope.where("business_object_id = ?", current_object.id)
  end

  def list_of_variables(current_object)
    DeployedSkill.where("business_object_id = ?", current_object).select("id, code, name")
  end

end
