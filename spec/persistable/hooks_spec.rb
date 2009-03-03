require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class HooksSpecClass
  include Persistable
  class << self; attr_accessor :before_load_hook, :after_load_hook, :before_delete_hook, :after_delete_hook end
  attr_accessor :before_hook, :after_hook
  before(:save) { |obj| obj.before_hook = 'BEFORE' }
  after(:save) { |obj| obj.after_hook = "AFTER" }
  
  before(:load) { |klass| klass.before_load_hook = "BEFORE LOAD" }
  after(:load) { |klass| klass.after_load_hook = "AFTER LOAD" }

  before(:delete) { |klass| klass.before_delete_hook = "BEFORE DELETE" }
  after(:delete) { |klass| klass.after_delete_hook = "AFTER DELETE" }
  
  def key; 'test' end
  def to_storage_hash; {} end
  def self.from_storage_hash(attrs); new() end
end

describe "Hooks" do
  describe "#before" do
    it "should allow adding before hooks to save" do
      klass = HooksSpecClass.new
      klass.save
      klass.before_hook.should == 'BEFORE'
    end

    it "should allow adding before hooks to load" do
      HooksSpecClass.new.save
      HooksSpecClass.load("test")
      HooksSpecClass.before_load_hook.should == 'BEFORE LOAD'
    end
    
    it "should allow adding before hooks to delete" do
      HooksSpecClass.new.save
      HooksSpecClass.delete('test')
      HooksSpecClass.before_delete_hook.should == 'BEFORE DELETE'
    end
  end
  
  describe "#after" do
    it "should allow adding after hooks to save" do
      klass = HooksSpecClass.new
      klass.save
      klass.after_hook.should == 'AFTER'
    end
    
    it "should allow adding after hooks to load" do
      HooksSpecClass.new.save
      HooksSpecClass.load("test")
      HooksSpecClass.after_load_hook.should == 'AFTER LOAD'
    end
    
    it "should allow adding after hooks to delete" do
      HooksSpecClass.new.save
      HooksSpecClass.delete('test')
      HooksSpecClass.after_delete_hook.should == 'AFTER DELETE'
    end
  end
end