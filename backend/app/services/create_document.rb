class CreateDocument
  include Interactor

  def call
    document = Document.create!(status: :pending, file: context.file)
    context.document = document
  end
end