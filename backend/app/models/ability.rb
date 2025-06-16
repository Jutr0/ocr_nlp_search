# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: 'guest')

    if user.superadmin?
      can :manage, :all
    elsif user.user?
      can :manage, User, id: user.id
      can :manage, Document, user_id: user.id
    end
  end
end
