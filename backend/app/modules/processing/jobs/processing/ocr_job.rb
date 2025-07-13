require 'rtesseract'
require 'mini_magick'
require 'pdf/reader'
module Processing
  class OcrJob < ApplicationJob
    queue_as :default

    def perform(document)
      document = StructUtils.deep_ostruct(document)
      return unless document&.file_url.present?

      tempfile = Tempfile.new(['doc', File.extname(document.filename)])
      tempfile.binmode
      tempfile.write URI.open(document.file_url).read
      tempfile.rewind
      file_path = tempfile.path

      OcrStartedEvent.call(document)

      extracted_text = if document.content_type == 'application/pdf'
                         extract_text_from_pdf(file_path)
                       else
                         extract_text_from_image(file_path)
                       end
      document.text_ocr = extracted_text.strip

      OcrSucceededEvent.call(document)

      NlpJob.perform_later(document.to_h.slice(:text_ocr, :document_id))
    rescue => e
      Rails.logger.error "[OCRJob] Error on Document #{document.document_id}: #{e.message}"
      OcrFailedEvent.call(document, { message: e.message })
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
      RTesseract.new(image.path, lang: 'pol', psm: 6, processor: 'hocr').to_s
    end

    def extract_text_from_pdf(path)
      text = extract_text_from_pdf_directly(path)
      if text.length > 100
        text
      else
        image_paths = convert_pdf_to_images(path)
        image_paths.map { |img| extract_text_from_image(img) }.join("\n---\n")
      end
    end

    def convert_pdf_to_images(pdf_path)

      MiniMagick::Tool::Convert.new do |convert|
        convert.density(300)
        convert.background('white')
        convert.alpha('remove')
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
