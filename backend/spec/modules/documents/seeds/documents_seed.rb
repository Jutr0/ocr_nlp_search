module Documents
  RSpec.shared_examples 'documents_seed' do
    include_examples 'basic_seed'

    let(:file) { fixture_file_upload('dummy.pdf', 'application/pdf') }

    let(:pending_document) { Document.find_by(status: :pending, user: user) }
    let(:approved_document) { Document.find_by(status: :approved, user: user) }
    let(:another_user_document) { Document.find_by(status: :pending, user: another_user) }


    before(:each) do
      populate_documents
    end

    private

    def populate_documents
      [
        { user: user },
        { user: user, company_name: 'Beta LLC', invoice_number: 'INV-002', issue_date: "2025-08-12", status: :approved },
        { user: another_user }
      ].each do |attrs|
        Document.create!({ file:, **attrs })
      end
    end
  end
end
