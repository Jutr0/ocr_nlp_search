require "openai"

module Processing
  module Llm
    class OpenAi < Base
      def initialize(api_key:, model:)
        @client = OpenAI::Client.new(access_token: api_key)
        @model = model
      end

      def complete(prompt, system: nil, json: false)
        messages = []
        messages << { role: "system", content: system } if system
        messages << { role: "user", content: prompt }

        parameters = {
          model: @model,
          temperature: 0,
          messages: messages
        }
        parameters[:response_format] = { type: "json_object" } if json

        response = @client.chat(parameters: parameters)

        response.dig("choices", 0, "message", "content")
      end
    end
  end
end
