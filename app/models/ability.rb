class Ability
  include CanCan::Ability

  def initialize(user)

    if user && user.admin?
      can :index, Dashboard

      can :manage, User
      can :generate_api_secret, User
      can :manage, Relic
      can :manage, SuggestedType
      can :manage, Document
      can :manage, Photo
      can :manage, Entry
      can :manage, Alert
      can :manage, WuozAgency
      can :manage, Autocomplition

      can :index, Version
      can :show, Version
      can :revert, Version
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
  end
end
