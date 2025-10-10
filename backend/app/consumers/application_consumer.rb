class ApplicationConsumer < Karafka::BaseConsumer

  protected
  def parse_payload(message)
    JSON.parse(message.raw_payload, object_class: OpenStruct)
  end
end
