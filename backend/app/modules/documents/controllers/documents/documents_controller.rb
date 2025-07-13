module Documents
  class DocumentsController < ApplicationController
    include ActiveStorage::SetCurrent
    load_and_authorize_resource
    before_action :check_to_review_status, only: [:approve, :reject]
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
      DocumentOcrRefreshEvent.call(@document)
      head :ok
    end

    def refresh_nlp
      DocumentNlpRefreshEvent.call(@document)
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

    def check_to_review_status
      unless @document.to_review?
        @document.errors.add(:status, "must be in to_review state")
        raise ActiveRecord::RecordInvalid.new(@document)
      end
    end

  end
end
