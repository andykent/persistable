require File.join(File.dirname(__FILE__), '..', 'spec_helper')

[
  Persistable::StorageEngines::InMemory.new,
  Persistable::StorageEngines::FileSystem.new(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'fs_spec_store')),
  Persistable::StorageEngines::TokyoCabinetHashDB.new(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'tchdb_spec.tch')),
].each do |storage_engine|

  class Person
    include Persistable
    def initialize(attributes); @attributes = attributes end
    def to_storage_hash; @attributes end
    def self.from_storage_hash(attrs) new(attrs) end
    def key; @attributes['name'] end
    def name; @attributes['name'] end
    def email; @attributes['email']end
  end

  describe storage_engine.class.name do
    before :all do
      Person.reset_persistable_defaults
      Person.use :storage_engine, storage_engine
    end
    
    after(:each) { Person.clear! }
    
    describe "#persistable?" do
      it "returns true if the class is persistable, false otherwise" do
        Person.should be_persistable
        String.should_not be_persistable
      end
    end
    
    describe ".save" do
      it "saves an entry and returns true if successful" do
        andy = Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com')
        andy.save.should == true
      end
    end
    
    describe "#config" do
      it "provides access to the settings" do
        Person.config(:storage_engine).should == storage_engine
      end
    end

    describe "#load" do
      it "loads a record back into ruby" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person.load('Andy').email.should == 'andy.kent@me.com'
      end
      
      it "can take multiple values to do a batch load" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person.new('name' => 'Mike', 'email' => 'mike.jones@trafficbroker.co.uk').save
        Person.load_batch(['Andy', 'Mike']).first.email.should == 'andy.kent@me.com'        
        Person.load_batch(['Andy', 'Mike']).last.email.should == 'mike.jones@trafficbroker.co.uk'        
      end
      
      it "raises a Persistable::NotFound if a non-existent key is provided" do
        lambda { Person.load('houdini') }.should raise_error(Persistable::NotFound)
      end
      
      it "is aliased as Class[key]" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person['Andy'].email.should == 'andy.kent@me.com'        
      end
    end

    describe "#each" do
      it "iterates through all records in this collection" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person.new('name' => 'Mark', 'email' => 'mark@kent.com').save
        count = 0
        Person.each do |key, person| 
          count += 1
          %w(Andy Mark).include?(person.name).should == true 
        end
        count.should == 2
      end
    end

    describe "#count, #size" do
      it "returns the number of records in a collection" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person.new('name' => 'Mark', 'email' => 'mark@kent.com').save
        Person.count.should == 2
        Person.size.should == 2
      end
    end

    describe "#clear!" do
      it "wipes all data from this collection" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person.new('name' => 'Mark', 'email' => 'mark@kent.com').save
        Person.clear!
        Person.count.should == 0
      end
    end
    
    describe "#exists?" do
      it "returns true if the key exists in the collection" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person.exists?("Andy").should == true
        Person.exists?("Mark").should == false
      end
    end
    
    describe "#delete" do
      it "deletes a key from the collection" do
        Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com').save
        Person.exists?("Andy").should == true
        Person.delete("Andy")
        Person.exists?("Andy").should == false
      end
    end
    
    describe ".delete" do
      it "deletes the current object from the collection" do
        p = Person.new('name' => 'Andy', 'email' => 'andy.kent@me.com')
        p.save
        Person.exists?("Andy").should == true
        p.delete
        Person.exists?("Andy").should == false
      end
    end
  end
end