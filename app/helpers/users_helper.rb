module UsersHelper

# retrieve the list of responsible users
  def set_responsibles_list
    @responsibles_list = User.all
  end

# retrieve the list of approval users
  def approvers_list
    @approvers_list = User.joins(groups: :roles).select("users.name", "users.id").where("parameters.property = 'Data Steward'")
  end

# retrieve the list of approval users
  def set_users_list
    @users_list = User.all
  end

  # retrieve the list of users groups
  def set_groups_list
    @groups_list = Group.all
  end

  def user_roles_list(user)
    @roles_list = User.joins(groups: :roles).distinct.where("users.id = ?", user.id).select("parameters.property").map(&:property)
    @roles_list.to_s[1..-2]
  end

end
