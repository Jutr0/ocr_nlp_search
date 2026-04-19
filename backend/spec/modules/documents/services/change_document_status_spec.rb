require 'rails_helper'

RSpec.describe Documents::ChangeDocumentStatus, type: :interactor do
  let(:document) { create(:document) }

  describe "updating status" do
    it "updates document status and creates history log" do
      result = described_class.call(
        document_id: document.id,
        status: :ocr_processing,
        action: :ocr_started
      )

      expect(result).to be_success
      document.reload
      expect(document.status).to eq("ocr_processing")
      expect(document.history_logs.last.action).to eq("ocr_started")
    end

    it "updates document status with extra attributes" do
      result = described_class.call(
        document_id: document.id,
        status: :ocr_succeeded,
        action: :ocr_succeeded,
        attributes: { text_ocr: "Extracted text" }
      )

      expect(result).to be_success
      document.reload
      expect(document.status).to eq("ocr_succeeded")
      expect(document.text_ocr).to eq("Extracted text")
    end

    it "updates document to to_review with extracted fields" do
      result = described_class.call(
        document_id: document.id,
        status: :to_review,
        action: :nlp_succeeded,
        attributes: { category: "utilities_and_subscriptions", company_name: "Acme Co" }
      )

      expect(result).to be_success
      document.reload
      expect(document.status).to eq("to_review")
      expect(document.category).to eq("utilities_and_subscriptions")
      expect(document.company_name).to eq("Acme Co")
    end

    it "does nothing when document does not exist" do
      result = described_class.call(
        document_id: SecureRandom.uuid,
        status: :ocr_processing,
        action: :ocr_started
      )

      expect(result).to be_success
    end
  end
end
