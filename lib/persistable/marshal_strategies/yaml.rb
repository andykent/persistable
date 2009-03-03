module Persistable
  module MarshalStrategies
    class YAML
      def initialize
        require 'yaml'
      end
      
      def to_storage(hash)
        ::YAML.dump(hash)
      end
      
      def from_storage(string)
        ::YAML.load(string)
      end
    end
  end
end