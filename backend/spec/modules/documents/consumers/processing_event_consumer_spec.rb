require 'rails_helper'
require 'modules/documents/seeds/documents_seed'
module Documents
  RSpec.describe ProcessingEventConsumer, type: :consumer do
    include_examples "documents_seed"
    subject(:consumer) { described_class.new }

    def make_message(event, data)
      payload = { event: event, data: data }.to_json
      double("message", raw_payload: payload)
    end

    shared_examples "updates status" do |event, expected_status, extra_attrs = {}|
      it "sets status to #{expected_status} on #{event}" do
        msg = make_message(event, { document_id: pending_document.id }.merge(extra_attrs))
        allow(consumer).to receive(:messages).and_return([msg])

        consumer.consume
        pending_document.reload

        expect(pending_document.status).to eq(expected_status.to_s)

        extra_attrs.each_key do |attr|
          expect(pending_document.public_send(attr)).to eq(extra_attrs[attr])
        end
      end
    end

    describe "#consume" do
      context "when document does not exist" do
        it "skips messages for missing docs" do
          msg = make_message("processing.ocr.started", document_id: SecureRandom.uuid)
          allow(consumer).to receive(:messages).and_return([msg])

          expect { consumer.consume }.not_to raise_error
        end
      end

      include_examples "updates status", "processing.ocr.started", :ocr_processing
      include_examples "updates status", "processing.ocr.failed", :ocr_retrying
      include_examples "updates status", "processing.ocr.succeeded", :ocr_succeeded,
                       "text_ocr" => "Extracted OCR text"
      include_examples "updates status", "processing.nlp.started", :nlp_processing
      include_examples "updates status", "processing.nlp.failed", :nlp_retrying

      context "processing.nlp.succeeded" do
        it "sets status to to_review and updates extracted fields" do
          extracted = { "category" => "utilities_and_subscriptions", "company_name" => "Acme Co" }
          msg = make_message("processing.nlp.succeeded",
                             document_id: pending_document.id,
                             extracted_fields: extracted)
          allow(consumer).to receive(:messages).and_return([msg])

          consumer.consume
          pending_document.reload

          expect(pending_document.status).to eq("to_review")
          expect(pending_document.category).to eq("utilities_and_subscriptions")
          expect(pending_document.company_name).to eq("Acme Co")
        end
      end
    end
  end
end