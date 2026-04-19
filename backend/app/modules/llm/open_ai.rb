require "openai"

module Llm
  class OpenAi < Base
    def initialize(api_key:, model:)
      @client = OpenAI::Client.new(access_token: api_key)
      @model = model
    end

    def complete(prompt, system: nil)
      messages = []
      messages << { role: "system", content: system } if system
      messages << { role: "user", content: prompt }

      response = @client.chat(
        parameters: {
          model: @model,
          temperature: 0,
          messages: messages
        }
      )

      response.dig("choices", 0, "message", "content")
    end
  end
end
