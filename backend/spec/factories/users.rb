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
FactoryBot.define do
  factory :user, class: "Users::User" do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :user }

    trait :superadmin do
      role { :superadmin }
    end

    trait :guest do
      role { :guest }
    end
  end
end
