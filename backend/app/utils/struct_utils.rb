module StructUtils
  class << self
    def deep_ostruct(obj)
      case obj
      when Hash
        OpenStruct.new(obj.transform_values { |v| deep_ostruct(v) })
      when Array
        obj.map { |v| deep_ostruct(v) }
      else
        obj
      end
    end
  end
end
