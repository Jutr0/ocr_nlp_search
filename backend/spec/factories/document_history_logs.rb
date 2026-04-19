# == Schema Information
#
# Table name: document_history_logs
#
#  id             :uuid             not null, primary key
#  action         :string           not null
#  current_state  :string
#  previous_state :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  document_id    :uuid             not null
#
# Indexes
#
#  index_document_history_logs_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
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
