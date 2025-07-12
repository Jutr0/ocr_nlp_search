require 'helpers/schema_loader'
def load_spec_request(name)
  SpecSchemas::SpecLoader.new(name, 'requests').load
end

def load_spec_response(name)
  SpecSchemas::SpecLoader.new(name, 'responses').load
end
def get_spec_response_path(name)
  SpecSchemas::SpecLoader.new(name, 'responses').path
end
