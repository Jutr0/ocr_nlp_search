# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: 'guest')

    if user.superadmin?
      can :manage, :all
    else
      can :read, User, id: user.id
      can :update, User, id: user.id
    end
  end
end
