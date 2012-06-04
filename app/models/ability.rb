class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all

    if user && user.admin?
      can :history, Relic
      can :update, Relic
      can :revert, Relic
    end

    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
