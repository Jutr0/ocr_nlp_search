require 'rails_helper'

RSpec.describe Documents::UpdateDocument, type: :interactor do
  let(:document) { create(:document, :to_review, invoice_number: "OLD-001", company_name: "Old Co") }

  describe '#call' do
    context 'with valid editable attributes' do
      it 'succeeds' do
        result = described_class.call(document: document, attributes: { invoice_number: "NEW-001" })
        expect(result).to be_success
      end

      it 'updates the document fields' do
        described_class.call(document: document, attributes: { invoice_number: "NEW-001", company_name: "New Co" })
        document.reload
        expect(document.invoice_number).to eq("NEW-001")
        expect(document.company_name).to eq("New Co")
      end

      it 'creates an edited history log' do
        expect {
          described_class.call(document: document, attributes: { invoice_number: "NEW-001" })
        }.to change(Documents::DocumentHistoryLog, :count).by(1)

        log = document.history_logs.last
        expect(log.action).to eq("edited")
      end
    end

    context 'with non-editable attributes' do
      it 'ignores status and other non-editable fields' do
        described_class.call(document: document, attributes: { invoice_number: "X-1", status: "approved", text_ocr: "hacked" })
        document.reload
        expect(document.invoice_number).to eq("X-1")
        expect(document.status).to eq("to_review")
      end
    end

    context 'with empty attributes' do
      it 'fails the interactor' do
        result = described_class.call(document: document, attributes: {})
        expect(result).to be_failure
        expect(result.error[:status]).to eq(:unprocessable_entity)
      end
    end

    context 'with only blank values' do
      it 'fails the interactor' do
        result = described_class.call(document: document, attributes: { invoice_number: "", company_name: "" })
        expect(result).to be_failure
        expect(result.error[:status]).to eq(:unprocessable_entity)
      end
    end
  end
end
