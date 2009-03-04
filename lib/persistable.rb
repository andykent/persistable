require "rubygems"

kcode = 'u'
$LOAD_PATH.unshift File.dirname(__FILE__)

require "indexable"
require "sphinx_searchable"

require "persistable/guid_generator"

require "persistable/mixins/class_methods"
require "persistable/mixins/instance_methods"

require "persistable/marshal_strategies/json"
require "persistable/marshal_strategies/yaml"
require "persistable/marshal_strategies/ruby_marshal"

require "persistable/storage_engines/file_system"
require "persistable/storage_engines/in_memory"
require "persistable/storage_engines/tokyo_cabinet_hdb"

module Persistable
  class Error < StandardError; end
  class ConnectionError < Persistable::Error; end
  class NotImplemented < Persistable::Error; end
  class NotFound < Persistable::Error; end
  
  class << self
    def with_mutex(&blk)
      (@mutex ||= Mutex.new).synchronize(&blk)
    end
  end
  
  def self.included(c)
    c.send(:extend, Mixins::ClassMethods)
    c.send(:include, Mixins::InstanceMethods)
    c.reset_persistable_defaults
  end
end

class Object
  def self.persistable?
    self.ancestors.include?(Persistable)
  end
end