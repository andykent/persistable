module Persistable
  
  def self.included(c)
    c.send(:extend, Mixins::ClassMethods)
    c.send(:include, Mixins::InstanceMethods)
    c.reset_persistable_defaults
  end
  
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
        load_from_hash(self.config(:marshal_strategy).from_storage(config(:storage_engine).read(k)))
      end
      
      private
      
      def load_from_hash(data)
        if config(:load).is_a?(Proc) 
          config(:load).call(data)
        else
          send(config(:load).to_sym, data)
        end
      end
    end
  
    module InstanceMethods
      def save
        config(:storage_engine).write( generate_key, config(:marshal_strategy).to_storage( hash_for_saving ) )
        true
      rescue
        false
      end
      
      def config(option)
        self.class.config(option)
      end
      
      private
      
      def generate_key
        if config(:key).is_a?(Proc) 
          instance_eval(&config(:key))
        else
          send(config(:key).to_sym)
        end
      end
      
      def hash_for_saving
        if config(:save).is_a?(Proc) 
          instance_eval(&config(:save))
        else
          send(config(:save).to_sym)
        end
      end
    end    
  end
  
  module StorageEngines
    class ConnectionError < StandardError; end
    
    class TokyoCabinetHashDB
      def initialize(file)
        require 'rubygems'
        require 'tokyocabinet'
        @connection = TokyoCabinet::HDB::new
        unless @connection.open(file, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)
          raise ConnectionError, @connection.errmsg(@connection.ecode)
        end
      end
      
      def read(k)
        @connection[k.to_s]
      end
      
      def write(k,v)
        @connection[k.to_s] = v.to_s
      end
    end
    
    class FileSystem
      def initialize(dir=Dir.pwd)
        @dir = dir
      end
      
      def read(k)
        File.read(file(k))
      end
      
      def write(k,v)
        File.open(file(k)) {|f| f << v }
      end
      
      private
      
      def file(k)
        File.join(@dir, k)
      end
    end
    
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
    end
  end
  
  module MarshalStrategies
    class JSON
      def initialize
        require 'rubygems'
        require 'json'
      end
      
      def to_storage(hash)
        ::JSON.dump(hash)
      end
      
      def from_storage(string)
        ::JSON.parse(string)
      end
    end
    
    class YAML
      def initialize
        require 'yaml'
      end
      
      def to_storage(hash)
        ::YAML.dump(hash)
      end
      
      def from_storage(string)
        ::YAML.load(string)
      end
    end
    
    class RubyMarshal
      def initialize
        require "base64"
      end
      
      def to_storage(hash)
        Base64.encode64(::Marshal.dump(hash))
      end
      
      def from_storage(string)
        ::Marshal.load(Base64.decode64(string))
      end
    end
  end
end