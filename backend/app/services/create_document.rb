class CreateDocument
  include Interactor

  def call
    document = Document.create!(status: :pending, file: context.file, filename: context.file.original_filename, user_id: context.user_id)
    context.document = document
    OcrJob.perform_later(document.id)
  end
end