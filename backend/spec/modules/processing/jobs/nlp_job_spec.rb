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
      allow(NlpStartedEvent).to receive(:call)
      allow(NlpSucceededEvent).to receive(:call)
      allow(NlpFailedEvent).to receive(:call)

      fake_response = { "choices" => [{ "message" => { "content" => response_text } }] }
      fake_client = instance_double(OpenAI::Client, chat: fake_response)
      allow(OpenAI::Client).to receive(:new).and_return(fake_client)
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
          expect(NlpStartedEvent).not_to receive(:call)
          expect(OpenAI::Client).not_to receive(:new)
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

        it 'calls started, succeeds, and populates extracted_fields properly' do
          expect(NlpStartedEvent).to receive(:call).with(instance_of(OpenStruct))

          NlpJob.perform_now(document_hash)

          succeeded_struct = nil
          expect(NlpSucceededEvent).to have_received(:call) do |doc_struct|
            succeeded_struct = doc_struct
          end

          expect(succeeded_struct.extracted_fields).to eq(
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
        end
      end

      context 'when an exception is raised during NLP' do
        let(:text_ocr) { 'irrelevant text' }
        let(:response_text) { '' }

        it 'logs error, fires failed event, and re-raises' do
          allow(OpenAI::Client).to receive(:new).and_raise(StandardError.new("boom"))

          expect(NlpStartedEvent).to receive(:call).with(instance_of(OpenStruct))
          expect(NlpFailedEvent).to receive(:call).with(
            instance_of(OpenStruct),
            hash_including(message: "boom")
          )

          expect { NlpJob.perform_now(document_hash) }.to raise_error(StandardError, "boom")

        end
      end
    end
  end
end
