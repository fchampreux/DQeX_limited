module AnnotationsHelper
  def annotation_types
    list_id = ParametersList.where("code=?", "LIST_OF_ANNOTATION_TYPES").take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end
end
