class Ability
  include CanCan::Ability

  def initialize(user)

    if user && user.admin?
      can :index, Dashboard

      can :manage, User
      can :manage, Relic
      can :manage, SuggestedType
      can :index, Version
      can :show, Version
      can :manage, Document
      can :manage, Photo
      can :manage, Entry
    end

    if user
      can :update, Relic
      can :create, Photo
      can :manage, Photo, :user_id => user.id
      can :create, Document
      can :manage, Document, :user_id => user.id
      can :manage, Link
      can :manage, Entry
      can :manage, Event
      can :create, Alert
    end

    can :create, User

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
