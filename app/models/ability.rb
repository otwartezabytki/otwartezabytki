class Ability
  include CanCan::Ability

  def initialize(user)

    if user && user.admin?
      can :index, Dashboard

      can :index, User
      can :edit, User
      can :update, User
      can :show, User
      can :generate_api_secret, User

      can :manage, Relic
      can :history, Relic
      can :update, Relic
      can :revert, Relic

      can :manage, SuggestedType
      can :history, SuggestedType
      can :update, SuggestedType
      can :revert, SuggestedType
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
