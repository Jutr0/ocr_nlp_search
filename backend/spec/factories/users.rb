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
