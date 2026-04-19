require "net/http"
require "json"

module Llm
  class Llama < Base
    def initialize(url:, model:)
      @url = url
      @model = model
    end

    def complete(prompt, system: nil)
      uri = URI("#{@url}/api/chat")

      messages = []
      messages << { role: "system", content: system } if system
      messages << { role: "user", content: prompt }

      body = { model: @model, messages: messages, stream: false }

      response = Net::HTTP.post(uri, body.to_json, "Content-Type" => "application/json")
      parsed = JSON.parse(response.body)

      parsed.dig("message", "content")
    end
  end
end
