require 'rails_helper'
module Processing
  RSpec.describe DocumentsConsumer, type: :consumer do
    subject(:consumer) { described_class.new }

    before(:each) do
      allow(OcrJob).to receive(:perform_later)
      allow(NlpJob).to receive(:perform_later)
    end

    def make_message(event)
      payload = { event: event, data: { data: "some data" } }.to_json
      double("message", raw_payload: payload)
    end

    context "starts ocr job" do
      it "because of documents.created" do
        msg = make_message("documents.created")
        allow(consumer).to receive(:messages).and_return([msg])

        expect(OcrJob).to receive(:perform_later).with({ data: "some data" })
        expect(NlpJob).not_to receive(:perform_later)
        consumer.consume
      end

      it "because of documents.ocr.refresh" do
        msg = make_message("documents.ocr.refresh")
        allow(consumer).to receive(:messages).and_return([msg])

        expect(OcrJob).to receive(:perform_later).with({ data: "some data" })
        expect(NlpJob).not_to receive(:perform_later)
        consumer.consume
      end
    end
    context "starts nlp job" do
      it "because of documents.nlp.refresh" do
        msg = make_message("documents.nlp.refresh")
        allow(consumer).to receive(:messages).and_return([msg])

        expect(NlpJob).to receive(:perform_later).with({ data: "some data" })
        expect(OcrJob).not_to receive(:perform_later)
        consumer.consume
      end

    end
  end
end