module Persistable
  module Mixins
    module ClassMethods
      def reset_persistable_defaults
        @config = {}
        use :load, :new
        use :save, :to_hash
        use :storage_engine, StorageEngines::InMemory.new
        use :marshal_strategy, MarshalStrategies::RubyMarshal.new
        use :key, :key
      end
      
      def use(option, value=nil, &blk)
        @config[option.to_sym] = value || blk
      end
      
      def config(option)
        @config[option.to_sym]
      end
    
      def load(k)
        load_from_storage(config(:storage_engine).read(k))
      end
      
      def each
        config(:storage_engine).each do |k, v|
          yield(k, load_from_storage(v))
        end
      end

      def count
        config(:storage_engine).count
      end
      alias size count
      
      def clear!
        config(:storage_engine).clear!
      end
      
      def exists?(k)
        config(:storage_engine).has_key?(k)
      end
      
      def before_instance_method(method, &blk)
        add_instance_aspect(:before, method, &blk)
      end
      
      def after_instance_method(method, &blk)
        add_instance_aspect(:after, method, &blk)
      end
      
      def before_class_method(method, &blk)
        add_class_aspect(:before, method, &blk)
      end
      
      def after_class_method(method, &blk)
        add_class_aspect(:after, method, &blk)
      end
      
      private
      
      def add_instance_aspect(position, method, &blk)
        Aquarium::Aspects::Aspect.new(position, :calls_to => method, :for_type => self) do |join_point, obj, sym, *args|
          obj.instance_eval(&blk)
        end
      end
      
      def add_class_aspect(position, method, &blk)
        Aquarium::Aspects::Aspect.new(position, :calls_to => method, :method_options => [:class], :for_type => self) do |join_point, obj, sym, *args|
          obj.class_eval(&blk)
        end
      end
      
      def load_from_storage(data)
        load_from_hash(config(:marshal_strategy).from_storage(data))
      end
      
      def load_from_hash(data)
        if config(:load).is_a?(Proc) 
          config(:load).call(data)
        else
          send(config(:load).to_sym, data)
        end
      end
    end
  end
end