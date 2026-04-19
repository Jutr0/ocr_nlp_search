module Processing
  module Llm
    class Base
      def complete(prompt, system: nil, json: false)
        raise NotImplementedError, "#{self.class}#complete must be implemented"
      end
    end
  end
end
