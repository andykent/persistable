require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class PersonIndexableSpecClass
  include Persistable
  include Indexable
  index :auto_increment, :store => Persistable::StorageEngines::InMemory.new
  index :email, :store => Persistable::StorageEngines::InMemory.new
  def initialize(attributes) @attributes = attributes end
  def self.from_storage_hash(attributes); new(attributes) end
  def to_storage_hash; @attributes end
  def key; @attributes['name'] end
  def name; @attributes['name'] end
  def email; @attributes['email']end
end


describe Persistable::Indexable do
  before :each do
    @andy = PersonIndexableSpecClass.new('name' => 'Andy', 'email' => 'andy.kent@me.com')
    @andy.save
    PersonIndexableSpecClass.new('name' => 'Joe', 'email' => 'joe@bloggs.com').save
  end
  
  after :each do
    PersonIndexableSpecClass.clear!
  end
  
  it "allows querying unique indexes on any string attribute" do
    PersonIndexableSpecClass.load_via_index(:email, 'andy.kent@me.com').name.should == 'Andy'
  end
  
  it "removes items from the index on deletion" do
    @andy.delete
    PersonIndexableSpecClass.stub!(:load)
    lambda { PersonIndexableSpecClass.load_via_index(:email, 'andy.kent@me.com') }.should raise_error(Persistable::NotFound)   
  end
  
  it "allows auto incrementing indexes" do
    PersonIndexableSpecClass.load_via_index(:auto_increment, 1).name.should == 'Andy'
    PersonIndexableSpecClass.load_via_index(:auto_increment, 2).name.should == 'Joe'
  end
end