module Documents
  class CreateHistoryLog
    include Interactor

    def call
      DocumentHistoryLog.create(document: context.document, action: context.action, previous_state: context.previous_state, current_state: context.current_state)
    end
  end
end