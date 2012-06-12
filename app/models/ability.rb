class Ability
  include CanCan::Ability

  def initialize(user)

    if user && user.admin?
      can :index, Dashboard

      can :index, User
      can :edit, User
      can :update, User
      can :show, User

      can :manage, Relic
      can :history, Relic
      can :update, Relic
      can :revert, Relic
    else

    end

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
