require 'rails_helper'

RSpec.describe Documents::Document, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user).class_name('Users::User') }
    it { is_expected.to have_many(:history_logs).class_name('Documents::DocumentHistoryLog').dependent(:destroy) }
    it { is_expected.to have_one_attached(:file) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:document)).to be_valid
    end

    it 'is invalid without a file' do
      expect(build(:document, :without_file)).not_to be_valid
    end

    it 'is invalid with an unsupported file content type' do
      document = build(:document, :with_invalid_file)
      expect(document).not_to be_valid
      expect(document.errors[:file]).to be_present
    end

    it 'is valid with a PDF file' do
      document = build(:document)
      expect(document.file.content_type).to eq("application/pdf")
      expect(document).to be_valid
    end

    it 'is valid with a PNG file' do
      document = build(:document)
      document.file.attach(
        io: StringIO.new("fake png content"),
        filename: "test.png",
        content_type: "image/png"
      )
      expect(document).to be_valid
    end

    it 'is valid with a JPEG file' do
      document = build(:document)
      document.file.attach(
        io: StringIO.new("fake jpeg content"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
      expect(document).to be_valid
    end

    it 'is invalid without a status' do
      document = build(:document)
      document.status = nil
      expect(document).not_to be_valid
      expect(document.errors[:status]).to be_present
    end
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:status)
        .with_values(
          pending: "pending",
          ocr_processing: "ocr_processing",
          ocr_retrying: "ocr_retrying",
          ocr_succeeded: "ocr_succeeded",
          nlp_processing: "nlp_processing",
          nlp_retrying: "nlp_retrying",
          to_review: "to_review",
          approved: "approved"
        )
        .backed_by_column_of_type(:string)
    }

    it 'defaults to pending status' do
      expect(Documents::Document.new.status).to eq("pending")
    end

    it {
      expect(subject).to define_enum_for(:category)
        .with_values(
          it_services: "it_services",
          office_supplies: "office_supplies",
          travel_and_transportation: "marketing_and_advertising",
          marketing_and_advertising: "marketing_and_advertising",
          legal_and_accounting: "legal_and_accounting",
          utilities_and_subscriptions: "utilities_and_subscriptions",
          other: "other"
        )
        .backed_by_column_of_type(:string)
    }

    it 'defaults to other category' do
      expect(Documents::Document.new.category).to eq("other")
    end
  end

  describe '#only_to_review_can_be_approved' do
    context 'when transitioning from to_review to approved' do
      it 'is valid' do
        document = create(:document, :to_review)
        document.status = :approved
        expect(document).to be_valid
      end
    end

    context 'when transitioning from pending to approved' do
      it 'is invalid' do
        document = create(:document)
        document.status = :approved
        expect(document).not_to be_valid
        expect(document.errors[:status]).to be_present
      end
    end

    context 'when transitioning from ocr_succeeded to approved' do
      it 'is invalid' do
        document = create(:document, :ocr_succeeded)
        document.status = :approved
        expect(document).not_to be_valid
        expect(document.errors[:status]).to be_present
      end
    end

    context 'when transitioning between non-approved statuses' do
      it 'is valid' do
        document = create(:document)
        document.status = :ocr_processing
        expect(document).to be_valid
      end
    end
  end

  describe 'nip normalization' do
    it 'truncates nip to 10 characters' do
      document = build(:document, nip: "12345678901234")
      document.valid?
      expect(document.nip).to eq("1234567890")
    end

    it 'keeps nip unchanged when 10 characters or fewer' do
      document = build(:document, nip: "1234567890")
      document.valid?
      expect(document.nip).to eq("1234567890")
    end

    it 'leaves nil nip as nil' do
      document = build(:document, nip: nil)
      document.valid?
      expect(document.nip).to be_nil
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated history_logs when document is destroyed' do
      document = create(:document)
      create(:document_history_log, document: document)
      expect { document.destroy }.to change(Documents::DocumentHistoryLog, :count).by(-1)
    end
  end
end
