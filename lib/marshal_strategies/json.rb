module Persistable
  module MarshalStrategies
    class JSON
      def initialize
        require 'rubygems'
        require 'json'
      end
      
      def to_storage(hash)
        ::JSON.dump(hash)
      end
      
      def from_storage(string)
        ::JSON.parse(string)
      end
    end
  end
end