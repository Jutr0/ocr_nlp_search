# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': '127.0.0.1:9092' }
    config.client_id = 'ocr_nlp_search'
    config.group_id = 'ocr_nlp_search_consumer'
    config.consumer_persistence = !Rails.env.development?
  end

  Karafka.monitor.subscribe(
    Karafka::Instrumentation::LoggerListener.new(log_polling: true)
  )
  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(Karafka.logger, log_messages: false)
  )

  routes.draw do
    topic :documents_stream do
      consumer Processing::DocumentCreatedConsumer
    end
  end
end
