require File.join(File.dirname(__FILE__), '..', 'spec_helper')

[
  Persistable::StorageEngines::InMemory.new,
  Persistable::StorageEngines::FileSystem.new(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'fs_spec_store')),
  Persistable::StorageEngines::TokyoCabinetHashDB.new(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'tchdb_spec.tch')),
].each do |storage_engine|

  class Person
    include Persistable
    def initialize(attributes); @attributes = attributes end
    def to_hash; @attributes end
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
  end
end