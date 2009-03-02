kcode = 'u'
$LOAD_PATH << File.dirname(__FILE__)

require "mixins/class_methods"
require "mixins/instance_methods"

require "marshal_strategies/json"
require "marshal_strategies/yaml"
require "marshal_strategies/ruby_marshal"

require "storage_engines/file_system"
require "storage_engines/in_memory"
require "storage_engines/tokyo_cabinet_hdb"



module Persistable
  class Error < StandardError; end
  class ConnectionError < Persistable::Error; end
  class NotImplemented < Persistable::Error; end
  
  def self.included(c)
    c.send(:extend, Mixins::ClassMethods)
    c.send(:include, Mixins::InstanceMethods)
    c.reset_persistable_defaults
  end
end