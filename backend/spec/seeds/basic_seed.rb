RSpec.shared_examples "basic_seed" do
  DEFAULT_PASSWORD = 'password123'.freeze

  let(:superadmin) { User.find_by(role: :superadmin) }
  let(:user) { User.find_by(role: :user) }

  before(:each) do
    populate_users
  end

  private

  def populate_users
    User.create!(email: 'superadmin@example.com', password: DEFAULT_PASSWORD, role: :superadmin)
    User.create!(email: 'user@example.com', password: DEFAULT_PASSWORD, role: :user)
  end
end
