# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    user ||= User.new # guest user (not logged in)

    user_roles_list = User.joins(groups: :roles).where("users.id = ?", user.id).select("parameters.code").map(&:code)
    # Creating a session variable at user's login would avoid many queries!

    # Create aliases for additional actions
    alias_action :get_children, :to => :read
    alias_action :activate, :make_current, :finalise, :new_version, :propose,
                 :create_values_list, :upload_values_list, :remove_values_list, :to => :update
    alias_action :derive, :open_cart, :close_cart, :add_to_cart, :to => :build
    alias_action :new, :propose, :to => :create

    # Specific superadmin authorisations
    if user.is_admin
      can :manage, :all
    else
      can :translate, User if user.is_admin
      can :extract, ValuesList, is_finalised: true
      can :read, :all
      can :set_external_reference, :all
      can :update, User, id: user.id        # User can modify his own information
      #can :update, :all, owner_id: user.id  # User can modifiy data he owns (he created)
      can :update, [Playground, BusinessArea, BusinessFlow] if user_roles_list.include? 'ADMIN'
      can [:see_details, :export, :administrate], :all if user_roles_list.include? 'ADMIN'
      can [:govern], :all if user_roles_list.include? 'STEWARD'
      can [:see_details, :export], :all if user_roles_list.include? 'AUTHOR'
      #can [:create, :update, :build, :destroy], [DefinedObject, DefinedSkill, ValuesList, Classification, DeployedObject] if user_roles_list.include? 'AUTHOR' # Author can update someone else's Skills
      can [:create, :update, :build, :destroy], [DefinedObject, DefinedSkill, ValuesList, Classification, DeployedObject] if user_roles_list.include? 'STEWARD' # Author can update someone else's Skills
      can [:accept, :reject], [DefinedSkill, ValuesList, Classification, DeployedObject] if user_roles_list.include? 'STEWARD'
      can :manage, [BusinessProcess, DefinedSkill, DeployedSkill, Notification, Value, BusinessRule] if user_roles_list.include? 'VALIDATOR'
      can :manage, [DefinedObject, DeployedObject, BusinessFlow, BusinessProcess, Activity, Task] if user_roles_list.include? 'AUTHOR'
      can :build, [DefinedSkill, DeployedSkill]  if user_roles_list.include? 'VALIDATOR'
      can :manage, [Organisation,Territory] if user_roles_list.include? 'ADMIN'
      can :manage, [ProductionEvent, ProductionGroup, ProductionJob, ProductionSchedule, ProductionExecution] if user_roles_list.include? 'AUTHOR'
    end

  end
end
