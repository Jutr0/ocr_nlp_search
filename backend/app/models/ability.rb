# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Users::User.new(role: 'guest')

    Users::Abilities.define(self, user)
    Documents::Abilities.define(self, user)

  end
end
