# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :uuid             not null, primary key
#  exp        :datetime
#  jti        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti)
module Users
  class JwtDenylist < ApplicationRecord
    include Devise::JWT::RevocationStrategies::Denylist

    self.table_name = "jwt_denylists"
  end
end
