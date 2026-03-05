require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe NlpJob, type: :job do
  include ActiveJob::TestHelper
  include_examples 'documents_seed'

  let(:document) { approved_document }

  before do
    allow(ChangeDocumentStatus).to receive(:call!)
    allow(CompleteDocumentNlp).to receive(:call!)

    fake_response = { "choices" => [ { "message" => { "content" => response_text } } ] }
    fake_client = instance_double(OpenAI::Client, chat: fake_response)
    allow(OpenAI::Client).to receive(:new).and_return(fake_client)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '#perform' do
    context 'when text_ocr is blank' do
      let(:document) { pending_document }
      let(:response_text) { '' }

      it 'does nothing' do
        expect(ChangeDocumentStatus).not_to receive(:call!)
        expect(OpenAI::Client).not_to receive(:new)
        described_class.perform_now(document)
      end
    end

    context 'when NLP succeeds' do
      let(:parsed_json) do
        {
          document_type: "invoice",
          net_amount: "123.45",
          gross_amount: "150.00",
          currency: "PLN",
          category: "it_services",
          invoice_number: "INV-123",
          issue_date: "2025-07-12",
          company_name: "Acme Co",
          nip: "1234567890"
        }
      end
      let(:response_text) { "Here you go: \n#{parsed_json.to_json}\n" }

      it 'calls nlp_started and completes NLP with extracted data' do
        expect(ChangeDocumentStatus).to receive(:call!).with(document: document, action: :nlp_started)
        expect(CompleteDocumentNlp).to receive(:call!).with(
          document: document,
          extracted_data: hash_including(
            doc_type: "invoice",
            net_amount: 123.45,
            gross_amount: 150.00,
            currency: "PLN",
            category: "it_services",
            invoice_number: "INV-123",
            issue_date: "2025-07-12",
            company_name: "Acme Co",
            nip: "1234567890"
          )
        )

        described_class.perform_now(document)
      end
    end

    context 'when an exception is raised during NLP' do
      let(:response_text) { '' }

      before do
        allow(OpenAI::Client).to receive(:new).and_raise(StandardError.new("boom"))
        allow(ChangeDocumentStatus).to receive(:call)
      end

      it 'logs error, calls nlp_failed status, and re-raises' do
        expect(ChangeDocumentStatus).to receive(:call!).with(document: document, action: :nlp_started)
        expect(ChangeDocumentStatus).to receive(:call).with(document: document, action: :nlp_failed)

        expect { described_class.perform_now(document) }.to raise_error(StandardError, "boom")
      end
    end
  end
end
