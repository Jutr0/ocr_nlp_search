module Documents
  class DocumentsController < ApplicationController
    include ActiveStorage::SetCurrent
    load_and_authorize_resource

    def index
    end

    def show
    end

    def destroy
      @document.destroy!
      head :ok
    end

    def create
      result = CreateDocument.call!(**@document.attributes, file: document_params[:file])

      @document = result.document
      render json: { id: @document.id, status: @document.status }, status: :created
    end

    def refresh_ocr
      Processing::OcrJob.perform_later(
        document_id: @document.id,
        file_url: @document.file.url,
        filename: @document.filename,
        content_type: @document.file.content_type,
        user_id: @document.user_id
      )
      head :ok
    end

    def refresh_nlp
      Processing::NlpJob.perform_later(
        document_id: @document.id,
        text_ocr: @document.text_ocr
      )
      head :ok
    end

    def to_review
      @documents = @documents.to_review
    end

    def approve
      ApproveDocument.call!(document: @document)
      head :ok
    end

    def reject
      RejectDocument.call!(document: @document)
      head :ok
    end

    private

    def document_params
      params.permit(:file)
    end
  end
end
