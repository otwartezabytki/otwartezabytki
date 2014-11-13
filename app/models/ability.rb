# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)

    if user
      if user.admin?
        can :manage, :all
      else
        can :update, Relic
        can :create, Photo
        can :manage, Photo, :user_id => user.id
        can :create, Document
        can :manage, Document, :user_id => user.id
        can :manage, Link
        can :manage, Entry
        can :manage, Event
        can :create, Alert
        can [:update, :remove_avatar], User, :id => user.id
        can [:read, :added_relics, :checked_relics, :my_routes, :walking_guides], User
        can [:edit, :update, :destroy], Widget::Direction, :user_id => user.id
        can [:edit, :update, :destroy], Widget::WalkingGuide, :user_id => user.id
      end
    end

    can :create, User
  end
end
