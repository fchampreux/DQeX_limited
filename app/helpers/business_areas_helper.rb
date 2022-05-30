module BusinessAreasHelper

  def list_of_business_areas
    BusinessArea.where("is_active").select("id", "name")
  end

end
