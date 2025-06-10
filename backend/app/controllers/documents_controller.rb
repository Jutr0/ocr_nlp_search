class DocumentsController < ApplicationController

  def index
    @documents = Document.all.to_a
    @documents.concat(Document.all.to_a)
    @documents.concat(Document.all.to_a)
    @documents.concat(Document.all.to_a)
  end

  def create
    result = CreateDocument.call!(file: document_params[:file])

    @document = result.document
    render json: { id: @document.id, status: @document.status }, status: :created
  end

  private

  def document_params
    params.permit(:file)
  end
end
