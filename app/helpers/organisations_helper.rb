module OrganisationsHelper

  def list_of_organisations
    @organisations_list = Organisation.where("is_active").select("id", "name")
  end

end
