require 'rails_helper'

RSpec.describe OcrJob, type: :job do
  include ActiveJob::TestHelper

  let(:document_hash) do
    {
      document_id: SecureRandom.uuid,
      file_url: 'http://example.com/foo.pdf',
      filename: 'foo.pdf',
      content_type: content_type
    }
  end

  before do
    allow(OcrStartedEvent).to receive(:call)
    allow(OcrSucceededEvent).to receive(:call)
    allow(OcrFailedEvent).to receive(:call)
    allow(NlpJob).to receive(:perform_later)

    fake_file = StringIO.new("PDFDATA")
    allow(URI).to receive(:open).with(document_hash[:file_url]).and_return(fake_file)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '#perform' do
    context 'when file_url is blank' do
      let(:content_type) { 'application/pdf' }

      it 'does nothing' do
        dh = document_hash.merge(file_url: nil)
        expect(OcrStartedEvent).not_to receive(:call)
        OcrJob.perform_now(dh)
      end
    end

    context 'when content_type is application/pdf and text > 100 chars' do
      let(:content_type) { 'application/pdf' }

      it 'calls started, succeeds, and enqueues NLP once' do
        pdf_text = 'A' * 150
        reader = double('PDF::Reader', pages: [ double('page', text: pdf_text) ])
        allow(PDF::Reader).to receive(:new).and_return(reader)

        expect(OcrStartedEvent).to receive(:call).with(instance_of(OpenStruct))
        expect(OcrSucceededEvent).to receive(:call).with(instance_of(OpenStruct))

        OcrJob.perform_now(document_hash)

        expect(NlpJob).to have_received(:perform_later).with(
          hash_including(text_ocr: pdf_text, document_id: document_hash[:document_id])
        )
      end
    end

    context 'when content_type is application/pdf but direct text short' do
      let(:content_type) { 'application/pdf' }

      it 'falls back to image OCR for each page' do
        reader = double('PDF::Reader', pages: [ double('page', text: 'short') ])
        allow(PDF::Reader).to receive(:new).and_return(reader)

        allow_any_instance_of(Processing::OcrJob).to receive(:convert_pdf_to_images)
                                                       .and_return(%w[/tmp/foo-001.png /tmp/foo-002.png])

        allow_any_instance_of(Processing::OcrJob).to receive(:extract_text_from_image)
                                                       .with('/tmp/foo-001.png').and_return('ONE')
        allow_any_instance_of(Processing::OcrJob).to receive(:extract_text_from_image)
                                                       .with('/tmp/foo-002.png').and_return('TWO')

        expect(OcrStartedEvent).to receive(:call)
        expect(OcrSucceededEvent).to receive(:call)

        OcrJob.perform_now(document_hash)

        expect(NlpJob).to have_received(:perform_later).with(
          hash_including(text_ocr: "ONE\n---\nTWO", document_id: document_hash[:document_id])
        )
      end
    end

    context 'when content_type is an image' do
      let(:content_type) { 'image/png' }

      it 'uses image OCR path' do
        ocr_text = 'i got text'
        allow_any_instance_of(Processing::OcrJob).to receive(:extract_text_from_image)
                                                       .and_return(ocr_text)

        expect(OcrStartedEvent).to receive(:call)
        expect(OcrSucceededEvent).to receive(:call)

        OcrJob.perform_now(document_hash.merge(content_type: 'image/png'))

        expect(NlpJob).to have_received(:perform_later).with(
          hash_including(text_ocr: ocr_text.strip, document_id: document_hash[:document_id])
        )
      end
    end

    context 'when an exception is raised during OCR' do
      let(:content_type) { 'image/png' }

      it 'logs error, fires failed event, and re-raises' do
        allow_any_instance_of(Processing::OcrJob).to receive(:extract_text_from_image)
                                                       .and_raise(StandardError.new("boom"))

        expect(OcrFailedEvent).to receive(:call).with(
          instance_of(OpenStruct),
          hash_including(message: "boom")
        )

        expect {
          OcrJob.perform_now(document_hash)
        }.to raise_error(StandardError, "boom")
      end
    end
  end
end
