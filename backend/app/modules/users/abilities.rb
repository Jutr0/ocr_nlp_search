module Users
  module Abilities
    def self.define(ability, user)

      if user.superadmin?
        ability.can :manage, User
      elsif user.user?
        ability.can :manage, User, id: user.id
      end
    end
  end
end