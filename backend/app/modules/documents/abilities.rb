  module Documents::Abilities
    def self.define(ability, user)
      if user.user?
        ability.can :manage, Document, user_id: user.id
      end
    end
end