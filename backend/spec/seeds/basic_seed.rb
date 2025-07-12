RSpec.shared_examples "basic_seed" do
  DEFAULT_PASSWORD = 'password123'.freeze

  let(:superadmin) { Users::User.find_by(role: :superadmin) }
  let(:user) { Users::User.find_by(email: 'user@example.com') }
  let(:another_user) { Users::User.find_by(email: 'another@example.com') }

  before(:each) do
    populate_users
  end

  around do |example|
    travel_to Time.zone.parse("2025-01-01")
    example.run
    travel_back
  end

  private

  def populate_users
    [
      { email: 'superadmin@example.com', role: :superadmin },
      { email: 'user@example.com' },
      { email: 'another@example.com' }
    ].each do |attrs|
      Users::User.create!({ password: DEFAULT_PASSWORD, **attrs })
    end
  end
end
