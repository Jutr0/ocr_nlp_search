module Users
  module Abilities
    def self.define(ability, user)

      if user.superadmin?
        ability.can :manage, User
      end
    end
  end
end