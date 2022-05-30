module ParametersHelper

  # retrieve a list of parameters
  def parameters_for(list, *scope)
    list_id = ParametersList.where("code=?", "LIST_OF_#{list.upcase}").take!
    Parameter.
    select("parameters.id, parameters.code, parameters.sort_code, parameters.property").
    where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now ).
    where(scope.any? ? "scope like '%#{scope[0]}%'" : "true").
    order("parameters.sort_code")
  end

  # retrieve a list of options for drop downs and enumerations
  def options_for(list, *scope)
    list_id = ParametersList.where("code=?", "LIST_OF_#{list.upcase}").take!
    Parameter.joins(:name_translations).
    select("parameters.id, parameters.code, parameters.sort_code, parameters.property, translations.translation as name").
    where("translations.language = ?", current_language).
    where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now ).
    where(scope.any? ? "scope like '%#{scope[0]}%'" : "true").
    order("parameters.sort_code")
  end

  # retrieve a list of options for drop downs and enumerations
  def values_options_for(list, level, *item_id)
    list_id = ValuesList.where("code=?", "CL_#{list.upcase}").take!
    Value.joins(:name_translations).
    select("values.parent_id, values.id, values.code, values.alternate_code, values.level, translations.translation as name").
    where("translations.language = ?", current_language).
    where("level = ? and values_list_id = ?", level, list_id ).
    where(item_id.any? ? "values.id = #{item_id[0]}" : "true").
    order("values.sort_code")
  end

# retrieve the list of statuses
  def set_statuses_list
    list_id = ParametersList.where("code=?", 'LIST_OF_STATUSES').take!
    @statuses_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

# retrieve the list of breach statuses
  def set_breach_statuses_list
    list_id = ParametersList.where("code=?", 'LIST_OF_BREACH_STATUSES').take!
    @breach_statuses_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrieve the list of notifications statuses
  def set_notification_statuses_list
    list_id = ParametersList.where("code=?", 'LIST_OF_BREACH_STATUSES').take!
    @notification_statuses_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  def statuses
    list_id = ParametersList.where("code=?", 'LIST_OF_STATUSES').take!
    ### provide object scope to manage various statuses regarding object classes
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

# retrieve the list of business rules types
  def set_rule_types_list
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_TYPES').take!
    @rule_types_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

# retrieve the list of business rules categories
  def set_rule_categories_list
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_CATEGORIES').take!
    @rule_categories_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

# retrieve the list of business severity
  def set_severity_list
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_SEVERITY').take!
    @severity_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

# retrieve the list of business complexity
  def set_complexity_list
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_COMPLEXITY').take!
    @complexity_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

# retrieve the assessment feature option
  def display_assessment?
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=?  AND ? BETWEEN active_from AND active_to", list_id, 'Show monitoring', Time.now ).take!
    @myparam.property == 'Yes'
  end

# retrieve the will_paginate number of lines per page
  def paginate_lines
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=?  AND ? BETWEEN active_from AND active_to", list_id, 'Nb of lines', Time.now ).take!
    @myparam.property.to_i
  end

# retrieve the currency
  def display_currency
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=?  AND ? BETWEEN active_from AND active_to", list_id, 'Currency', Time.now ).take!
    @myparam.property
  end

# retrieve the duration unit
  def display_duration
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=?  AND ? BETWEEN active_from AND active_to", list_id, 'Duration unit', Time.now ).take!
    @myparam.property
  end

# retrieve the time excursion for displaying history in objects tab
  def date_excursion
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=?  AND ? BETWEEN active_from AND active_to", list_id, 'Date excursion', Time.now ).take!
    @myparam.property.to_i
  end

# retrieve the logo filename
  def display_logo
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    if signed_in?
      @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Logo splash', Time.now ).take!
    else
      @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Logo filename', Time.now ).take!
    end
    @myparam.property
  end

# retrieve the traffic lights levels and filenames
  def red_threshold
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Tag 3-Red light', Time.now ).take!
    @myparam.property.to_i
  end

  def yellow_threshold
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Tag 2-Yellow light', Time.now ).take!
    @myparam.property.to_i
  end

  def green_threshold
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Tag 1-Green light', Time.now ).take!
    @myparam.property.to_i
  end

=begin
  def red_image
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Tag 3-Red light', Time.now ).take!
    @myparam.code
  end

  def yellow_image
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Tag 2-Yellow light', Time.now ).take!
    @myparam.code
  end

  def green_image
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Tag 1-Green light', Time.now ).take!
    @myparam.code
  end

  def grey_image
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    @myparam = Parameter.where("parameters_list_id=? AND name=? AND ? BETWEEN active_from AND active_to", list_id, 'Tag 4-Grey light', Time.now ).take!
    @myparam.code
  end
=end

# retrieve the list of data types
  def set_data_types_list
    list_id = ParametersList.where("code=?", 'LIST_OF_DATA_TYPES').take!
    @data_types_list = Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  #translation of parameters in drop-downs
=begin
    @data_types_list.each do |translate|
      translate.name = t(translate.name)
    end
=end
  end

# retrieve the list of users roles
  def set_roles_list
    list_id = ParametersList.where("code=?", 'LIST_OF_ROLES').take!
    @roles_list = Parameter.where("parameters_list_id=?  AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end


end
