class Documents::DocumentsController < ApplicationController
  include ActiveStorage::SetCurrent
  load_and_authorize_resource

  def index
  end

  def show
  end

  def destroy
    @document.destroy!
  end

  def create
    result = CreateDocument.call!(**@document.attributes, file: document_params[:file])

    @document = result.document
    render json: { id: @document.id, status: @document.status }, status: :created
  end

  def refresh_ocr
    OcrJob.perform_later(@document.id)
  end

  def refresh_nlp
    NlpJob.perform_later(@document.id)
  end

  private

  def document_params
    params.permit(:file)
  end
end
