module ActivitiesHelper

  # List activities with the given parent, exclude current activity if any
  # This is used to define activities chaining options in activity form
  def activities_of(parent, *exclude)
    if parent == 'templates'
      Activity.where(is_template: true)
    else
      if exclude[0]
        Activity.where("business_process_id = ? and id <> ?", parent, exclude)
      else
        Activity.where("business_process_id = ?", parent)
      end
    end
  end

end
