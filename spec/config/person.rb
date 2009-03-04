require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'persistable')

class PersonSearchableSpecClass
  include Persistable
  include Indexable
  include SphinxSearchable
  
  index :guid do
    use :storage_engine, Persistable::StorageEngines::InMemory.new
  end
  
  sphinx_index :people do
    set :max_matches, 100
    docid :guid # must be an integer and must have an index setup on this attr
    field :name
    field :email
    attribute :age, :int
  end
  
  def initialize(attributes) @attributes = attributes end
  def self.from_storage_hash(attributes); new(attributes) end
  def to_storage_hash; @attributes end
  def key; @attributes['name'] end
  def name; @attributes['name'] end
  def email; @attributes['email'] end
  def age; @attributes['age'] end
  def guid; @attributes['guid'] end
end