class CreateDocument
  include Interactor

  def call
    document = Document.create!(status: :pending, file: context.file, filename: context.file.original_filename)
    context.document = document
  end
end