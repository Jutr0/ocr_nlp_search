# frozen_string_literal: true

require "json"

module SpecSchemas
  class SpecLoader
    def initialize(filename, type)
      @filename = filename
      @type = type
    end

    def load
      JSON.parse(File.read(path))
    end

    def path
      spec_file = RSpec.current_example.metadata[:file_path]
      spec_abs = File.expand_path(spec_file, Dir.pwd)
      spec_dir = File.dirname(spec_abs)
      File.join(spec_dir, @type, "#{@filename}.json")
    end
  end
end
