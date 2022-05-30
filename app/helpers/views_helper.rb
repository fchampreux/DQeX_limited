module ViewsHelper

  # Idenfify the namespace of the controller
  def namespace
    case controller.class.parent.name
    when 'Object'
      nil
    when 'Devise'
      :administration
    else
      controller.class.parent.name.downcase
    end
  end

  ### ignore a block of code
  def ignore
  end

  ### provide full title of a page
  def full_title(page_title)
    base_title = "SIS Prototype"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  ### provide breadcrumbs for show or edit Views
  def breadcrumbs(object)
    way_back = [object]
    if object.class != Playground # do not consider the parents of a playground
      begin
        path = object.parent
        way_back << path
        object = path
      end until object.class == Playground # stop when comes to display the Playground
    end
    puts way_back.reverse
    way_back.reverse
  end

  # retrieve the list of playgrounds
  def list_of_playgrounds
    Playground.visible.joins(:name_translations)
      .select("playgrounds.id, playgrounds.code, translations.translation")
      .where("translations.language = ?", current_language)
      .order([Playground.arel_table[:hierarchy].asc])
  end

  # retrieve the list of business_objects to be used as templates
  def list_of_defined_metadata(business_process)
    business_area_id = business_process.parent.parent.id
    DefinedObject.where("parent_id = ? and parent_type = ?", business_area_id, 'BusinessArea').visible.select("id, code, name") # may be limited by access rights in the future
  end

=begin # Do not limit values_lists to current business area : share
  # retrieve the list of values_lists to be used as references
  def values_lists(skill)
    if skill.parent.parent.class == BusinessArea
      business_area = skill.parent.parent
    else
      business_area = skill.parent.parent.parent.parent
    end
    business_area.values_lists.visible.select("id, code, name") # may be limited by access rights in the future
  end

  def list_of_values_lists
    @values_lists = ValuesList.pgnd(current_playground).visible.select(:id, :code).order(:code)
  end
=end

  # retrieve the list of classifications, optionnaly related to a list of values
  def list_of_classifications(*values_list)
    if not values_list[0].blank?
      @classifications = Classification.joins(:values_lists_classifications).where("values_list_id = ?", values_list).visible.select(:id, :code)
    else
      @classifications = Classification.all.visible.select(:id, :code)
    end

  end

  # retrieve the list of business_objects to be used as templates
  def details_for_lists(skill)
    business_object = skill.parent
    business_object.skills.select("id, code, name") # may be limited by access rights in the future
  end

  # retrieve the list of organisations
  def list_of_organisations
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    organisation_level = Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to AND code = ?", list_id, Time.now, 'ORGANISATION_LEVEL' ).take.property
    Organisation.joins(:name_translations).
    select("organisations.code, organisations.id, translations.translation as name").
    where("translations.language = ?", current_language).
    where("organisations.id = 0 or organisation_level=?", organisation_level).order(:name)
  end

  # retrieve the list of organisations
  def list_of_owned_organisations
    list_id = ParametersList.where("code=?", 'LIST_OF_DISPLAY_PARAMETERS').take!
    owned_organisation = Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to AND code = ?", list_id, Time.now, 'ORGANISATION_ID' ).take.property
    Organisation.joins(:name_translations).
    select("organisations.id, organisations.code, translations.translation as name").
    where("translations.language = ?", current_language).
    where("organisations.id = 0 or organisation_id=?", owned_organisation).order(:name)
  end

  # retrieve the list of territories
  def list_of_territories
    Territory.joins(:name_translations).
    select("territories.id, territories.code, translations.translation as name").
    where("translations.language = ?", current_language).
    where("territories.id <> 0" )
  end

  # retrieve the list of users
  def list_of_users
    User.where("id <> 0").order(:name)
  end

  # create 2d array ready to be used as an options_for_select() parameter
  def get_options_from_list(list)
    list.map do |sl|
      #[sl.code, sl.id  ]
      [translation_for(sl.name_translations), sl.id  ]
    end
  end

  # retrive options for select from the given list
  def options_for_select_from_list(list, val)
    options_for_select(get_options_from_list(list), val)
  end

  # retrive tasks types for object scope
  def types_of_tasks(object)
    list_id = ParametersList.where("code=?", 'LIST_OF_TASKS_TYPES').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to AND scope = ?", list_id, Time.now, object.class )
  end

  # retrive DQM mocules
  def dqm_modules
    list_id = ParametersList.where("code=?", 'LIST_OF_DQM_MODULES').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now)
  end

  # retrive object types
  def qdm_object_types(scope)
        list_id = ParametersList.where("code=?", 'LIST_OF_OBJECT_TYPES').take!
    Parameter.where("parameters_list_id=? AND scope like ? AND ? BETWEEN active_from AND active_to", list_id, "%#{scope ||= 'manage'}%", Time.now )
  end

  # retrive object statuses
  def statuses
    list_id = ParametersList.where("code=?", 'LIST_OF_STATUSES').take!
    ### provide object scope to manage various statuses regarding object classes
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrieve set_rule_classes_list of rules
  def rules_classes
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_CLASSES').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrieve types of rules
  def rules_types
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_TYPES').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrive rules implementation options
  def rules_implemantations
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_IMPLEMENTATION').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrive rules complexity
  def rules_complexity
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_COMPLEXITY').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrive rules severity
  def rules_severity
    list_id = ParametersList.where("code=?", 'LIST_OF_RULES_SEVERITY').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrive breach types
  def breach_types
    list_id = ParametersList.where("code=?", 'LIST_OF_BREACH_TYPES').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrive breach statuses
  def breach_statuses
    list_id = ParametersList.where("code=?", 'LIST_OF_BREACH_STATUSES').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  # retrive users roles
  def user_roles
    list_id = ParametersList.where("code=?", 'LIST_OF_USER_ROLES').take!
    Parameter.where("parameters_list_id=? AND ? BETWEEN active_from AND active_to", list_id, Time.now )
  end

  def list_of_groups
    Group.visible.joins(:name_translations)
      .select("groups.id, groups.code, translations.translation as name")
      .where("translations.language = ?", current_language)
      .order(:code)
  end

  # retrive data units of measures
  def data_units
    list_id = ParametersList.where("code=?", 'LIST_OF_DATA_UNITS').take!
    Parameter.where("id = 0 or (parameters_list_id=? AND ? BETWEEN active_from AND active_to)", list_id, Time.now )
  end

  # retrive data types
  def sensitivity_grades
    list_id = ParametersList.where("code=?", 'LIST_OF_SENSITIVITY_GRADES').take!
    Parameter.where("id = 0 or (parameters_list_id=? AND ? BETWEEN active_from AND active_to)", list_id, Time.now )
  end

  # retrive data types
  def aggregation_methods
      list_id = ParametersList.where("code=?", 'LIST_OF_AGGREGATION_METHODS').take!
    Parameter.where("id = 0 or (parameters_list_id=? AND ? BETWEEN active_from AND active_to)", list_id, Time.now )
  end

=begin
  ### select audit tag filename based on DataMart score
  def activity_tag_for(current_object)
    current_period_day = Time.now.strftime("%Y%m%d")
    current_period_id = DimTime.where("period_day = ?", current_period_day).take.period_id
    if DmProcess.where("period_id = ? and ODQ_object_id = ?", current_period_id, current_object.id).blank?
      measured_score = -1
    else
      measured_score = DmProcess.where("period_id = ? and ODQ_object_id = ?", current_period_id, current_object.id).first.score
    end
    # select image file based on initialised constants
    image_file = case measured_score
      when -1 then $GreyImage
      when $GreenThreshold..100 then $GreenImage
      when $YellowThreshold..$GreenThreshold then $YellowImage
      else $RedImage
    end
    return image_file
  end
=end

  ### select activity tag filename based on status
  # turn is_active, is_current, is_finalised into colors
  def activity_tag_for(current_object)
    if not current_object.is_active
      image_file = $RedImage
    elsif current_object.is_finalised
      image_file = $GreenImage
      elsif current_object.is_current
        image_file = $YellowImage
      else
        image_file = $GreyImage
    end
  end

  ### return
  def status_class_for(current_object)
    if not current_object.is_active
      return "fa fa-archive status-inactive"
    elsif current_object.is_finalised
        return "fa fa-clipboard-check status-active"
      else
        return "fa fa-glasses status-pending"
    end
  end

  ### return true if the current controller should display the status indicators
  def show_status
    return ['business_objects', 'values_lists'].include? controller.controller_name
  end

  # Generatess a crash for BusinessArea without child
  def show_status_for_col(col) # Generatess a crash for BusinessArea without child
    # return ['BusinessObject', 'ValuesList'].include? col.first.class.name
    return true
  end

=begin
  # Return translation for current language
  def translation_for(translation)
    if translation.exists?(language: current_language)
      return translation.where('language = ?', current_language).first.translation
    elsif translation.exists?(language: 'en')
      return translation.where('language = ?', 'en').first.translation
    else
      return t('MissingTranslation')
    end
  end
=end

  def is_current_language(ln)
    return ln == current_language.to_s
  end

  def format_date(date)
    #return date.strftime("%Y.%m.%d %T") unless date.blank?
    return date.strftime("%Y.%m.%d") unless date.blank?
  end

  def format_datetime(date)
    #return date.strftime("%Y.%m.%d %T") unless date.blank?
    return date.strftime("%Y.%m.%d %T") unless date.blank?
  end

  def format_time(date)
    #return date.strftime("%Y.%m.%d %T") unless date.blank?
    return date.strftime("%T") unless date.blank?
  end

  def current_period_id
      current_period_id = TimeScale.where("period_date = ?", Time.now.to_date).take.period_id
  end

  def history_date
    DimTime.find(current_period_id - date_excursion).period_date
  end

  ### return object definition first row items column size
  def get_definition_col_size(item)
    if (show_status && (item.has_attribute? :major_version))
      return 4;
    end
    return 6;
  end

  ### return user name for the given login
  def get_user_name_from_login(login)
    user = User.find_by_user_name(login);
    if (user.present?)
      return user.name;
    end
    return login;
  end

end
