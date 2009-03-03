module Persistable
  module StorageEngines
    class InMemory
      def initialize
        @store = {}
      end
      
      def read(k)
        raise Persistable::NotFound, "Key '#{k}' could not be found." unless has_key?(k)
        @store[k.to_s]
      end
      
      def batch_read(keys)
        keys.map {|k| read(k) }
      end
      
      def write(k,v)
        @store[k.to_s] = v
      end
      
      def delete(k)
        @store.delete(k.to_s)
      end
      
      def each(&blk)
        @store.each(&blk)
      end
      
      def has_key?(k)
        @store.has_key?(k.to_s)
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