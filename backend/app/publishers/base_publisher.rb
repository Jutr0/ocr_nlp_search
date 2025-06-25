class BasePublisher
  def self.publish(topic:, event:, data:)
    Karafka.producer.produce_sync(topic: , payload: { event:, data: }.to_json)
  end
end