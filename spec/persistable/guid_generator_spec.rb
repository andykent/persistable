require File.join(File.dirname(__FILE__), '..', 'spec_helper')


describe "Persistable.guid" do
  it "should raise an error unless a store is set" do
    lambda { Persistable.guid }.should raise_error(Persistable::Error)
  end
  
  it "should give back a unique incrementing integer value each time it's called" do
    Persistable.guid_store = Persistable::StorageEngines::InMemory.new
    Persistable.guid.should == 1
    Persistable.guid.should == 2
    Persistable.guid.should == 3
  end
end