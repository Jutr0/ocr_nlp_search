require "rtesseract"
require "mini_magick"
require "pdf/reader"
module Processing
  class OcrJob < ApplicationJob
    queue_as :default

    def perform(document)
      document = StructUtils.deep_ostruct(document)
      return unless document&.file_url.present?

      tempfile = Tempfile.new([ "doc", File.extname(document.filename) ])
      tempfile.binmode
      tempfile.write URI.open(document.file_url).read
      tempfile.rewind
      file_path = tempfile.path

      Documents::ChangeDocumentStatus.call!(
        document_id: document.document_id,
        status: :ocr_processing,
        action: :ocr_started
      )

      ocr_result = if document.content_type == "application/pdf"
                      extract_text_from_pdf(file_path)
      else
                      extract_text_from_image(file_path)
      end

      extracted_text = ocr_result[:text].strip
      ocr_confidence = ocr_result[:confidence]

      Documents::ChangeDocumentStatus.call!(
        document_id: document.document_id,
        status: :ocr_succeeded,
        action: :ocr_succeeded,
        attributes: { text_ocr: extracted_text, ocr_confidence: ocr_confidence }
      )

      NlpJob.perform_later(text_ocr: extracted_text, document_id: document.document_id)
    rescue => e
      Rails.logger.error "[OCRJob] Error on Document #{document.document_id}: #{e.message}"
      Documents::ChangeDocumentStatus.call!(
        document_id: document.document_id,
        status: :ocr_retrying,
        action: :ocr_failed
      )
      raise e
    end

    private

    def extract_text_from_image(path)
      image = MiniMagick::Image.open(path)
      image.resize("400%")
      image.format("png")
      image.contrast
      image.density("300")
      image.sharpen("0x1.0")
      image.normalize
      image.despeckle

      tesseract = RTesseract.new(image.path, lang: "pol", psm: 6, processor: "hocr")
      text = tesseract.to_s
      confidence = extract_hocr_confidence(tesseract)

      { text: text, confidence: confidence }
    end

    def extract_text_from_pdf(path)
      text = extract_text_from_pdf_directly(path)
      if text.length > 100
        { text: text, confidence: 100 }
      else
        image_paths = convert_pdf_to_images(path)
        results = image_paths.map { |img| extract_text_from_image(img) }
        combined_text = results.map { |r| r[:text] }.join("\n---\n")
        confidences = results.map { |r| r[:confidence] }.compact
        avg_confidence = confidences.any? ? (confidences.sum / confidences.size) : nil

        { text: combined_text, confidence: avg_confidence }
      end
    end

    def extract_hocr_confidence(tesseract)
      hocr = tesseract.to_s_without_spaces rescue nil
      return nil unless hocr.is_a?(String)

      scores = hocr.scan(/x_wconf\s+(\d+)/).flatten.map(&:to_i)
      scores.any? ? (scores.sum / scores.size) : nil
    rescue
      nil
    end

    def convert_pdf_to_images(pdf_path)
      MiniMagick::Tool::Convert.new do |convert|
        convert.density(300)
        convert.background("white")
        convert.alpha("remove")
        convert << pdf_path
        convert << "#{pdf_path}-%03d.png"
      end

      Dir["#{pdf_path}-*.png"].sort
    end

    def extract_text_from_pdf_directly(path)
      text = ""
      PDF::Reader.new(path).pages.each do |page|
        text << page.text
      end
      text.strip
    end
  end
end
