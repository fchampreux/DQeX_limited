module TerritoriesHelper

  def list_of_territories
    @territories_list = Territory.where("is_active").select("id", "name")
  end

end
