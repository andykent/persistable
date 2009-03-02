module Persistable
  module StorageEngines
    class InMemory
      def initialize
        @store = {}
      end
      
      def read(k)
        @store[k]
      end
      
      def write(k,v)
        @store[k] = v
      end
      
      def each(&blk)
        @store.each(&blk)
      end
      
      def count
        @store.keys.size
      end
    end
  end
end