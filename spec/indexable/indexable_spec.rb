require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class PersonIndexableSpecClass
  include Persistable
  include Indexable
  index :email, :store => Persistable::StorageEngines::InMemory.new
  def initialize(attributes); @attributes = attributes end
  def to_hash; @attributes end
  def key; @attributes['name'] end
  def name; @attributes['name'] end
  def email; @attributes['email']end
end

describe Persistable::Indexable do
  it "allows querying unique indexes on any string attribute" do
    PersonIndexableSpecClass.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
    PersonIndexableSpecClass.new('name' => 'Joe', 'email' => 'joe@bloggs.com').save
    PersonIndexableSpecClass.load_via_index(:email, 'andy.kent@me.com').name.should == 'Andy'
  end
end