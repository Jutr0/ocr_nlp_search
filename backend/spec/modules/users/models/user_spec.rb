require 'rails_helper'

module Users
  RSpec.describe User, type: :model do
    include_examples 'basic_seed'

    describe 'enums' do
      it do
        is_expected.to define_enum_for(:role).
          with_values(user: 'user', superadmin: 'superadmin', guest: 'guest').
          backed_by_column_of_type(:string).
          with_default(:user)
      end
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
      it { is_expected.to allow_value('example@mail.com').for(:email) }
      it { is_expected.not_to allow_value('invalid_email').for(:email) }

      it { is_expected.to validate_presence_of(:password) }
      it { is_expected.to validate_confirmation_of(:password) }
      it { is_expected.to validate_length_of(:password).is_at_least(6).is_at_most(128) }
    end
  end
end
