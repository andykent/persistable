module Persistable
  module Indexable
    def self.included(c)
      c.send(:extend, Mixins::ClassMethods)
      c.send(:include, Mixins::InstanceMethods)
    end
    
    module Mixins
      module ClassMethods
        def index(property, opts={})
          raise ArgumentError, "a :store option must be provided" unless opts.has_key?(:store)
          if property === :auto_increment 
            indexes[property] = IncrementingIndex.new(opts[:store])
            self.after(:save) { |obj| obj.indexes[property].add_entry(obj.key) }
          else
            indexes[property] = UniqueIndex.new(opts[:store])
            self.after(:save) { |obj| obj.indexes[property].add_entry(obj.send(property), obj.key) }
            self.after(:delete) { |obj| obj.indexes[property].delete_entry(obj.send(property)) }
          end
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
      
      def initialize(store)
        @store = store
      end
      
      def add_entry(index_value, destination_key)
        @store.write(index_value.to_s, destination_key.to_s)
      end
      
      def delete_entry(index_value)
        @store.delete(index_value)
      end
      
      def find(key)
        @store.read(key)
      end
    end
    
    class IncrementingIndex
      def initialize(store)
        @store = store
        @store.write('__counter__', '0')
      end
      
      def add_entry(destination_key)
        @store.write(next_available_key, destination_key.to_s)
      end
      
      def delete_entry(index_value)
        @store.delete(index_value)
      end
      
      def find(key)
        @store.read(key.to_s)
      end
      
      private
      def next_available_key
        next_key = (@store.read('__counter__').to_i + 1).to_s
        @store.write('__counter__', next_key)
        next_key
      end
    end
  end
end
