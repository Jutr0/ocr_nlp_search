class DocumentsController < ApplicationController
  def create
    @document = CreateDocument.new(document_params[:file]).call

    render json: { id: @document.id, status: @document.status }, status: :created
  end

  private

  def document_params
    params.require(:document).permit(:file)
  end
end
