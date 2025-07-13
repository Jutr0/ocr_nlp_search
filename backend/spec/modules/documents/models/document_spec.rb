require 'rails_helper'
require 'modules/documents/seeds/documents_seed'
module Documents
  RSpec.describe Document, type: :model do
    include_examples 'documents_seed'

    let(:invalid_file) { fixture_file_upload('dummy.txt', 'text/plain') }

    describe 'associations' do
      it { is_expected.to belong_to(:user).class_name('Users::User') }
      it { is_expected.to have_one_attached(:file) }
    end

    describe 'enums' do
      it do
        is_expected.to define_enum_for(:status).
          with_values(
            pending: 'pending',
            ocr_processing: 'ocr_processing',
            ocr_retrying: 'ocr_retrying',
            ocr_succeeded: 'ocr_succeeded',
            nlp_processing: 'nlp_processing',
            nlp_retrying: 'nlp_retrying',
            to_review: 'to_review',
            approved: 'approved'
          ).
          backed_by_column_of_type(:string).
          with_default(:pending)
      end
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:status) }
      it { is_expected.to validate_presence_of(:file) }

      it 'is invalid with disallowed content type' do
        doc = Document.new(user: user)
        doc.file.attach(invalid_file)
        expect(doc).not_to be_valid
        expect(doc.errors[:file]).to include("has an invalid content type (authorized content types are PDF, PNG, JPG)")
      end

      it 'is valid with an allowed content type' do
        doc = Document.new(user: user)
        doc.file.attach(file)
        expect(doc).to be_valid
      end
    end

    describe 'callbacks' do
      it 'truncates nip to 10 characters before validation' do
        long_nip = '123456789012345'
        doc = Document.new(user: user, nip: long_nip)
        doc.file.attach(file)
        doc.valid?
        expect(doc.nip).to eq(long_nip[0, 10])
      end
    end
  end
end
