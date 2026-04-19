module Llm
  class Factory
    def self.build(backend: Rails.configuration.llm.backend)
      case backend
      when "openai"
        Llm::OpenAi.new(
          api_key: Rails.configuration.llm.openai_api_key,
          model: Rails.configuration.llm.openai_model
        )
      when "llama"
        Llm::Llama.new(
          url: Rails.configuration.llm.llama_url,
          model: Rails.configuration.llm.llama_model
        )
      else
        raise ArgumentError, "Unknown LLM backend: #{backend}"
      end
    end
  end
end
