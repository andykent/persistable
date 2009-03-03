module Persistable
  module MarshalStrategies
    class RubyMarshal
      def initialize
        require "base64"
      end

      def to_storage(hash)
        Base64.encode64(::Marshal.dump(hash))
      end

      def from_storage(string)
        ::Marshal.load(Base64.decode64(string))
      end
    end
  end
end