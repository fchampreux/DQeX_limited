module TasksHelper

  # List activities with the given parent, exclude current activity if any
  # This is used to define activities chaining options in activity form
  def tasks_of(parent, *exclude)
    if parent == 'templates'
      Task.where(is_template: true)
    else
      if exclude[0]
        Task.where("parent_type = 'Activity' and parent_id = ? and id <> ?", parent, exclude)
      else
        Task.where("parent_type = 'Activity' and parent_id = ?", parent)
      end
    end
  end

end
