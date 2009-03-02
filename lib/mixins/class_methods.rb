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
      
      private
      
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