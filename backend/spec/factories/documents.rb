FactoryBot.define do
  factory :document, class: "Documents::Document" do
    association :user
    status { :pending }
    filename { "test.pdf" }
    content_type { "application/pdf" }

    after(:build) do |document|
      document.file.attach(
        io: StringIO.new("%PDF-1.4 test content"),
        filename: "test.pdf",
        content_type: "application/pdf"
      )
    end

    trait :image do
      filename { "test.png" }
      content_type { "image/png" }

      after(:build) do |document|
        document.file.attach(
          io: StringIO.new("fake png content"),
          filename: "test.png",
          content_type: "image/png"
        )
      end
    end

    trait :ocr_processing do
      status { :ocr_processing }
    end

    trait :ocr_retrying do
      status { :ocr_retrying }
    end

    trait :ocr_succeeded do
      status { :ocr_succeeded }
    end

    trait :nlp_processing do
      status { :nlp_processing }
    end

    trait :nlp_retrying do
      status { :nlp_retrying }
    end

    trait :to_review do
      status { :to_review }
    end

    trait :with_ocr_text do
      text_ocr { "Faktura VAT nr FV/001/2024, kwota netto 1000.00, brutto 1230.00 PLN" }
    end

    trait :without_file do
      after(:build) do |document|
        document.file.detach
      end
    end

    trait :with_invalid_file do
      after(:build) do |document|
        document.file.attach(
          io: StringIO.new("just text content"),
          filename: "test.txt",
          content_type: "text/plain"
        )
      end
    end
  end
end
