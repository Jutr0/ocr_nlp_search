require 'rails_helper'

module Processing
  RSpec.describe NlpJob, type: :job do
    include ActiveJob::TestHelper

    let(:document_hash) do
      {
        document_id: SecureRandom.uuid,
        text_ocr: text_ocr
      }
    end

    before do
      allow(Documents::ChangeDocumentStatus).to receive(:call!).and_return(true)

      fake_adapter = instance_double(Processing::Llm::Base)
      allow(fake_adapter).to receive(:complete).and_return(response_text)
      allow(Processing::Llm::Factory).to receive(:build).and_return(fake_adapter)
    end

    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    describe '#perform' do
      context 'when text_ocr is blank' do
        let(:text_ocr) { nil }
        let(:response_text) { '' }

        it 'does nothing' do
          expect(Documents::ChangeDocumentStatus).not_to receive(:call!)
          expect(Processing::Llm::Factory).not_to receive(:build)
          NlpJob.perform_now(document_hash)
        end
      end

      context 'when NLP succeeds' do
        let(:text_ocr) { 'Some OCR text' }
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

        it 'reports started, succeeds, and passes extracted fields' do
          NlpJob.perform_now(document_hash)

          expect(Documents::ChangeDocumentStatus).to have_received(:call!).with(
            hash_including(document_id: document_hash[:document_id], status: :nlp_processing, action: :nlp_started)
          )
          expect(Documents::ChangeDocumentStatus).to have_received(:call!).with(
            hash_including(
              document_id: document_hash[:document_id],
              status: :to_review,
              action: :nlp_succeeded,
              attributes: {
                doc_type: "invoice",
                net_amount: 123.45,
                gross_amount: 150.00,
                currency: "PLN",
                category: "it_services",
                invoice_number: "INV-123",
                issue_date: "2025-07-12",
                company_name: "Acme Co",
                nip: "1234567890",
                nlp_confidence: nil
              }
            )
          )
        end
      end

      context 'when an exception is raised during NLP' do
        let(:text_ocr) { 'irrelevant text' }
        let(:response_text) { '' }

        it 'logs error, reports failure, and re-raises' do
          failing_adapter = instance_double(Processing::Llm::Base)
          allow(failing_adapter).to receive(:complete).and_raise(StandardError.new("boom"))
          allow(Processing::Llm::Factory).to receive(:build).and_return(failing_adapter)

          expect { NlpJob.perform_now(document_hash) }.to raise_error(StandardError, "boom")

          expect(Documents::ChangeDocumentStatus).to have_received(:call!).with(
            hash_including(status: :nlp_processing, action: :nlp_started)
          )
          expect(Documents::ChangeDocumentStatus).to have_received(:call!).with(
            hash_including(status: :nlp_retrying, action: :nlp_failed)
          )
        end
      end
    end
  end
end
