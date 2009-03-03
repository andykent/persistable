module Persistable
  module Mixins
    module InstanceMethods
      def save
        config(:storage_engine).write( key, config(:marshal_strategy).to_storage( hash_for_saving ) )
        true
      # rescue
      #   false
      end
      
      def config(option)
        self.class.config(option)
      end
      
      def key
        if config(:key).is_a?(Proc) 
          instance_eval(&config(:key))
        else
          send(config(:key).to_sym)
        end
      end
      
      private
      
      def hash_for_saving
        if config(:save).is_a?(Proc) 
          instance_eval(&config(:save))
        else
          send(config(:save).to_sym)
        end
      end
    end    
  end
end