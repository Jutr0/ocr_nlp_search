require "rails_helper"

RSpec.describe Users::JwtDenylist, type: :model do
  it "uses the jwt_denylists table" do
    expect(described_class.table_name).to eq("jwt_denylists")
  end

  it "includes the Devise JWT Denylist revocation strategy" do
    expect(described_class.ancestors).to include(Devise::JWT::RevocationStrategies::Denylist)
  end
end
