FactoryBot.define do
  factory :document_history_log, class: "Documents::DocumentHistoryLog" do
    association :document
    action { :created }

    trait :ocr_started do
      action { :ocr_started }
    end

    trait :ocr_failed do
      action { :ocr_failed }
    end

    trait :ocr_succeeded do
      action { :ocr_succeeded }
    end

    trait :nlp_started do
      action { :nlp_started }
    end

    trait :nlp_failed do
      action { :nlp_failed }
    end

    trait :nlp_succeeded do
      action { :nlp_succeeded }
    end

    trait :approved do
      action { :approved }
    end

    trait :rejected do
      action { :rejected }
    end

    trait :edited do
      action { :edited }
    end
  end
end
