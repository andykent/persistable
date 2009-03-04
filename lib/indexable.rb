module Persistable
  module Indexable
    def self.included(c)
      c.send(:extend, Mixins::ClassMethods)
      c.send(:include, Mixins::InstanceMethods)
    end
    
    module Mixins
      module ClassMethods
        def index(property, &blk)
          indexes[property] = UniqueIndex.new(self, property, &blk)
          self.after(:save) { |obj| obj.indexes[property].add_entry(obj) }
          self.after(:delete) { |obj| obj.indexes[property].delete_entry(obj) }
          self.after(:clear) { |klass| klass.indexes[property].clear! }
        end
        
        def indexes
          @indexes ||= {}
        end
        
        def rebuild_index(index_name)
          indexes[index_name].rebuild 
        end
        
        def load_via_index(index_name, key)
          load(indexes[index_name].find(key))
        end
        
        def load_batch_via_index(index_name, keys)
          destinations = keys.map {|key| indexes[index_name].find(key) }
          load_batch(destinations)
        end
      end
      
      module InstanceMethods
        def indexes
          self.class.indexes
        end
      end
    end
    
    class IndexEntry
      include Persistable
      attr_reader :my_key, :destination
      def initialize(my_key, destination)
        @my_key, @destination = my_key.to_s, destination.to_s
      end

      def to_storage_hash
        { 'my_key' => my_key, 'destination_key' => destination }
      end

      def self.from_storage_hash(attrs)
        new(attrs['my_key'], attrs['destination_key'])
      end
      
      def self.inherited(subclass)
        subclass.send(:include, Persistable)
        subclass.use(:key, :my_key)
      end
    end
    
    class UniqueIndex
      def initialize(klass, property, &blk)
        @klass, @property = klass, property
        @index_entry_class = Class.new(Persistable::Indexable::IndexEntry)
        @index_entry_class.class_eval(&blk)
      end
      
      def add_entry(obj)
        @index_entry_class.new(obj.send(@property), obj.key).save!
      end
      
      def delete_entry(obj)
        @index_entry_class.delete(obj.send(@property))
      end
      
      def find(key)
        @index_entry_class.load(key).destination
      end
      
      def size
        @index_entry_class.size
      end
      
      def rebuild
        clear!
        @klass.each {|k,obj| add_entry(obj) }
      end
      
      def clear!
        @index_entry_class.clear!
      end
    end
  end
end
