# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: "guest")

    if user.user?
      can :manage, Document, user_id: user.id
    elsif user.superadmin?
      can :manage, User
    end
  end
end
