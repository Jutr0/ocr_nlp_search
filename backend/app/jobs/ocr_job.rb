require 'rtesseract'
require 'mini_magick'
require 'pdf/reader'

class OcrJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    return unless document.file.attached?

    file_path = ActiveStorage::Blob.service.send(:path_for, document.file.key)

    document.update!(status: Document.statuses[:ocr_processing])
    extracted_text = if document.file.content_type == 'application/pdf'
                       extract_text_from_pdf(file_path)
                     else
                       extract_text_from_image(file_path)
                     end

    document.update!(text_ocr: extracted_text.strip, status: Document.statuses[:ocr_succeeded])
    NlpJob.perform_later(document.id)
  rescue => e
    Rails.logger.error "[OCRJob] Error on Document #{document_id}: #{e.message}"
    document.update!(status: Document.statuses[:ocr_failed]) if document
    raise e
  end

  private

  def extract_text_from_image(path)
    image = MiniMagick::Image.open(path)
    image.resize("400%")
    image.contrast
    image.sharpen("0x1.0")
    image.normalize
    image.despeckle
    RTesseract.new(image.path, lang: 'pol', psm: 11).to_s
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
      text << "\n---\n"
    end
    text.strip
  end
end
