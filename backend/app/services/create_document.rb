class CreateDocument
  def initialize(uploaded_file)
    @uploaded_file = uploaded_file
  end

  def call
    Document.transaction do
      doc = Document.create!(status: :pending)
      doc.file.attach(@uploaded_file)
      doc
    end
  end
end