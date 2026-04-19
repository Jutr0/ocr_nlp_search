module Llm
  class Base
    def complete(prompt, system: nil)
      raise NotImplementedError, "#{self.class}#complete must be implemented"
    end
  end
end
