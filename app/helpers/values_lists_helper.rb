module ValuesListsHelper
  def values_list_types
    list_id = ParametersList.where("code=?", "LIST_OF_VALUES_LISTS_TYPES").take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  def list_of_values_lists(*list_type)
    if !list_type.blank?
      @values_lists = ValuesList.visible.where(list_type_id: (values_list_types.find { |x| x["code"] == list_type }).id).select(:id, :code).order(:code)
    else
      @values_lists = ValuesList.visible.select(:id, :code).order(:code)
    end
  end
end
