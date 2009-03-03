module Persistable
  module Indexable
    def self.included(c)
      c.send(:extend, Mixins::ClassMethods)
      c.send(:include, Mixins::InstanceMethods)
    end
    
    module Mixins
      module ClassMethods
        def unique_index(property, opts={})
          raise ArgumentError, "a :store option must be provided" unless opts.has_key?(:store)
          indexes[property] = UniqueIndex.new(opts[:store])
          self.after_instance_method(:save) { self.indexes[property].add_entry(self.send(property), self.key) }
        end
        
        def indexes
          @indexes ||= {}
        end
        
        def load_via_index(index, key)
          load(indexes[index].find(key))
        end
      end
      
      module InstanceMethods
        def indexes
          self.class.indexes
        end
      end
    end
    
    class UniqueIndex
      include Persistable
      
      def initialize(store)
        @store = store
      end
      
      def add_entry(index_value, destination_key)
        @store.write(index_value.to_s, destination_key.to_s)
      end
      
      def find(key)
        @store.read(key)
      end
    end
  end
end