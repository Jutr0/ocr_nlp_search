require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(user) }

  describe "as a regular user" do
    let(:user) { create(:user) }
    let(:own_document) { create(:document, user: user) }
    let(:other_document) { create(:document) }

    it "can manage their own documents" do
      expect(ability).to be_able_to(:manage, own_document)
    end

    it "cannot manage another user's documents" do
      expect(ability).not_to be_able_to(:manage, other_document)
    end

    it "cannot manage User records" do
      expect(ability).not_to be_able_to(:manage, Users::User)
    end
  end

  describe "as a superadmin" do
    let(:user) { create(:user, :superadmin) }

    it "can manage all User records" do
      expect(ability).to be_able_to(:manage, Users::User)
    end

    it "cannot manage Document records" do
      expect(ability).not_to be_able_to(:manage, Documents::Document)
    end
  end

  describe "as a guest" do
    let(:user) { create(:user, :guest) }

    it "cannot manage Document records" do
      expect(ability).not_to be_able_to(:manage, Documents::Document)
    end

    it "cannot manage User records" do
      expect(ability).not_to be_able_to(:manage, Users::User)
    end
  end

  describe "with nil user" do
    let(:user) { nil }

    it "cannot manage Document records" do
      expect(ability).not_to be_able_to(:manage, Documents::Document)
    end

    it "cannot manage User records" do
      expect(ability).not_to be_able_to(:manage, Users::User)
    end
  end
end
