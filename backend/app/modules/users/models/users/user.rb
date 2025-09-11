# == Schema Information
#
# Table name: users
#
#  id                 :uuid             not null, primary key
#  email              :string           not null
#  encrypted_password :string           not null
#  role               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
#  index_users_on_email  (email) UNIQUE
module Users

  class User < ApplicationRecord
    devise :database_authenticatable,
           :registerable,
           :validatable,
           :jwt_authenticatable,
           jwt_revocation_strategy: JwtDenylist

    enum :role, { user: 'user', superadmin: 'superadmin', guest: 'guest' }, default: :user

  end
end
