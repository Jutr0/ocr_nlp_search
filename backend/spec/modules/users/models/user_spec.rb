require 'rails_helper'

RSpec.describe Users::User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:user)).to be_valid
    end

    it 'is invalid without an email' do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: "taken@example.com")
      duplicate = build(:user, email: "taken@example.com")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it 'is invalid without a password on create' do
      expect(build(:user, password: nil, password_confirmation: nil)).not_to be_valid
    end

    it 'is invalid when password is too short' do
      expect(build(:user, password: "short", password_confirmation: "short")).not_to be_valid
    end
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:role)
        .with_values(user: "user", superadmin: "superadmin", guest: "guest")
        .backed_by_column_of_type(:string)
    }

    it 'defaults to user role' do
      expect(Users::User.new.role).to eq("user")
    end
  end

  describe 'role predicates' do
    it 'returns true for user? when role is user' do
      expect(build(:user, role: :user)).to be_user
    end

    it 'returns true for superadmin? when role is superadmin' do
      expect(build(:user, :superadmin)).to be_superadmin
    end

    it 'returns true for guest? when role is guest' do
      expect(build(:user, :guest)).to be_guest
    end
  end
end
