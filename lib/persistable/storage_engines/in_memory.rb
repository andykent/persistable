module Persistable
  module StorageEngines
    class InMemory
      def initialize
        @store = {}
      end
      
      def read(k)
        raise Persistable::NotFound, "Key '#{k}' could not be found." unless has_key?(k)
        @store[k]
      end
      
      def write(k,v)
        @store[k] = v
      end
      
      def delete(k)
        @store.delete(k)
      end
      
      def each(&blk)
        @store.each(&blk)
      end
      
      def has_key?(k)
        @store.has_key?(k)
      end
      
      def count
        @store.keys.size
      end
      
      def clear!
        @store = {}
        true
      end
    end
  end
end