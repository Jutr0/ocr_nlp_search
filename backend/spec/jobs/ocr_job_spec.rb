require 'rails_helper'
require 'seeds/documents_seed'

RSpec.describe OcrJob, type: :job do
  include ActiveJob::TestHelper
  include_examples 'documents_seed'

  let(:document) { pending_document }

  before do
    allow(ChangeDocumentStatus).to receive(:call!)
    allow(CompleteDocumentOcr).to receive(:call!)
    allow(NlpJob).to receive(:perform_later)
    allow(URI).to receive(:open).and_return(StringIO.new("PDFDATA"))
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '#perform' do
    context 'when file is not attached' do
      let(:no_file_doc) do
        double('Document', file: double('file', attached?: false))
      end

      it 'does nothing' do
        expect(ChangeDocumentStatus).not_to receive(:call!)
        described_class.perform_now(no_file_doc)
      end
    end

    context 'when content_type is application/pdf and text > 100 chars' do
      before { allow(document).to receive(:content_type).and_return('application/pdf') }

      it 'calls ocr_started, completes OCR, and enqueues NLP' do
        pdf_text = 'A' * 150
        reader = double('PDF::Reader', pages: [ double('page', text: pdf_text) ])
        allow(PDF::Reader).to receive(:new).and_return(reader)

        expect(ChangeDocumentStatus).to receive(:call!).with(document: document, action: :ocr_started)
        expect(CompleteDocumentOcr).to receive(:call!).with(document: document, text_ocr: pdf_text)
        expect(NlpJob).to receive(:perform_later).with(document)

        described_class.perform_now(document)
      end
    end

    context 'when content_type is application/pdf but direct text is short' do
      before { allow(document).to receive(:content_type).and_return('application/pdf') }

      it 'falls back to image OCR for each page' do
        reader = double('PDF::Reader', pages: [ double('page', text: 'short') ])
        allow(PDF::Reader).to receive(:new).and_return(reader)

        allow_any_instance_of(OcrJob).to receive(:convert_pdf_to_images)
                                          .and_return(%w[/tmp/foo-001.png /tmp/foo-002.png])
        allow_any_instance_of(OcrJob).to receive(:extract_text_from_image)
                                          .with('/tmp/foo-001.png').and_return('ONE')
        allow_any_instance_of(OcrJob).to receive(:extract_text_from_image)
                                          .with('/tmp/foo-002.png').and_return('TWO')

        expect(CompleteDocumentOcr).to receive(:call!).with(document: document, text_ocr: "ONE\n---\nTWO")
        expect(NlpJob).to receive(:perform_later).with(document)

        described_class.perform_now(document)
      end
    end

    context 'when content_type is an image' do
      before { allow(document).to receive(:content_type).and_return('image/png') }

      it 'uses image OCR path' do
        ocr_text = 'i got text'
        allow_any_instance_of(OcrJob).to receive(:extract_text_from_image).and_return(ocr_text)

        expect(ChangeDocumentStatus).to receive(:call!).with(document: document, action: :ocr_started)
        expect(CompleteDocumentOcr).to receive(:call!).with(document: document, text_ocr: ocr_text.strip)
        expect(NlpJob).to receive(:perform_later).with(document)

        described_class.perform_now(document)
      end
    end

    context 'when an exception is raised during OCR' do
      before do
        allow(document).to receive(:content_type).and_return('application/pdf')
        allow_any_instance_of(OcrJob).to receive(:extract_text_from_pdf_directly).and_raise(StandardError.new("boom"))
        allow(ChangeDocumentStatus).to receive(:call)
      end

      it 'logs error, calls ocr_failed status, and re-raises' do
        expect(ChangeDocumentStatus).to receive(:call).with(document: document, action: :ocr_failed)

        expect {
          described_class.perform_now(document)
        }.to raise_error(StandardError, "boom")
      end
    end
  end
end
