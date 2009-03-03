module Persistable
  module StorageEngines
    class TokyoCabinetHashDB
      def initialize(file)
        require 'tokyocabinet'
        @connection = TokyoCabinet::HDB::new
        unless @connection.open(file, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)
          raise Persistable::ConnectionError, @connection.errmsg(@connection.ecode)
        end
      end
      
      def read(k)
        @connection[k.to_s]
      end
      
      def write(k,v)
        @connection[k.to_s] = v.to_s
      end
      
      def each
        @connection.iterinit
        while key = @connection.iternext
          yield(key, read(key))
        end
      end
      
      def count
        @connection.rnum
      end
      
      def clear!
        @connection.vanish
      end
    end
  end
end