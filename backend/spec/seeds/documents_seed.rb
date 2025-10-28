  RSpec.shared_examples 'documents_seed' do
    include_examples 'basic_seed'

    let(:file) { fixture_file_upload('dummy.pdf', 'application/pdf') }

    let(:pending_document) { Document.find_by(status: :pending, user: user) }
    let(:approved_document) { Document.find_by(status: :approved, user: user) }
    let(:to_review_document) { Document.find_by(status: :to_review, user: user) }
    let(:another_user_document) { Document.find_by(status: :pending, user: another_user) }
    let(:another_user_to_review_document) { Document.find_by(status: :to_review, user: another_user) }

    before do
      populate_documents
    end

    private

    def populate_documents
      document_extracted_params = {
        doc_type: "invoice", gross_amount: 10_000, net_amount: 9_000, category: "office_supplies"
      }

      [
        { user: user },
        { user: user, status: :approved, company_name: 'Beta LLC', invoice_number: 'INV-002', issue_date: "2025-08-12", text_ocr: "Beta LLC -- number INV-002 -- issued 2025-08-12", **document_extracted_params },
        { user: user, status: :to_review, company_name: 'Alpha Corp', invoice_number: 'INV-123', issue_date: "2024-03-15", text_ocr: "Alpha Corp -- number INV-123 -- issued 2024-03-15", **document_extracted_params },
        { user: another_user, status: :to_review, company_name: 'Delta Inc', invoice_number: 'INV-456', issue_date: "2024-02-28", text_ocr: "Delta Inc -- number INV-456 -- issued 2024-02-28", **document_extracted_params },
        { user: another_user }
      ].each do |attrs|
        Document.create!({ file:, filename: 'dummy.pdf', **attrs })
      end
  end
end
