module Persistable
  def self.guid
    raise Persistable::Error, "You must setup a guid store using Persistable.guid_store= MyStore before you can use Persistable.guid" unless @guid_generator
    @guid_generator.get_next_available_key
  end
  
  def self.guid_store=(store)
    @guid_generator = GuidGenerator.new(store)
  end
  
end


class GuidGenerator
  def initialize(store)
    @store = store
    @store.write('__counter__', '0')
  end
  
  def get_next_available_key
    next_key = (@store.read('__counter__').to_i + 1)
    @store.write('__counter__', next_key.to_s)
    next_key
  end
end