class BasePublisher
  def self.publish(topic:, event_type:, data:)
    Karafka.producer.produce_sync(topic: topic, payload: { event: event_type, data: data }.to_json)
  end
end