module Persistable
  module Mixins
    module ClassMethods
      def reset_persistable_defaults
        @config = {}
        @hooks = {}
        use :load, :from_storage_hash
        use :save, :to_storage_hash
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
    
      def load(key)
        load_from_storage(config(:storage_engine).read(key))
      end
      
      def load_batch(keys)
        results = config(:storage_engine).batch_read(keys)
        results.map {|r| load_from_storage(r) }
      end
      
      alias_method :[], :load
      
      def each
        config(:storage_engine).each do |k, v|
          yield(k, load_from_storage(v))
        end
      end

      def count
        config(:storage_engine).count
      end
      alias size count
      
      def delete(k)
        config(:storage_engine).delete(k)
      end
      
      def clear!
        run_hook(:before, :clear)
        config(:storage_engine).clear!
        run_hook(:after, :clear)
      end
      
      def exists?(k)
        config(:storage_engine).has_key?(k)
      end
      
      def before(action, &blk)
        add_hook(:before, action, &blk)
      end
      
      def after(action, &blk)
        add_hook(:after, action, &blk)
      end
      
      private
      
      def add_hook(position, action, &blk)
        hooks_for(position, action) << blk
      end
      
      def run_hook(position, action, obj=self)
        hooks_for(position, action).each { |blk| blk.call(obj) } 
      end
      
      def hooks_for(position, action)
        @hooks[:"#{position}_#{action}"] ||= []
      end
      
      def load_from_storage(data)
        run_hook(:before, :load)
        val = load_from_hash(config(:marshal_strategy).from_storage(data))
        run_hook(:after, :load)
        val
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