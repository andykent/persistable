require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class HooksSpecClass
  include Persistable
  class << self
    attr_accessor :before_load_hook, :after_load_hook , :before_clear_hook, :after_clear_hook
  end
  attr_accessor :before_hook, :after_hook, :before_delete_hook, :after_delete_hook
  before(:save) { |obj| obj.before_hook = 'BEFORE' }
  after(:save) { |obj| obj.after_hook = "AFTER" }
  
  before(:load) { |klass| klass.before_load_hook = "BEFORE LOAD" }
  after(:load) { |klass| klass.after_load_hook = "AFTER LOAD" }

  before(:delete) { |obj| obj.before_delete_hook = "BEFORE DELETE" }
  after(:delete) { |obj| obj.after_delete_hook = "AFTER DELETE" }

  before(:clear) { |klass| klass.before_clear_hook = "BEFORE CLEAR" }
  after(:clear) { |klass| klass.after_clear_hook = "AFTER CLEAR" }
  
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
      obj = HooksSpecClass.new
      obj.save
      obj.delete
      obj.before_delete_hook.should == 'BEFORE DELETE'
    end
    
    it "should allow adding before hooks to clear!" do
      HooksSpecClass.new.save
      HooksSpecClass.clear!
      HooksSpecClass.before_clear_hook.should == 'BEFORE CLEAR'
    end
  end
  
  describe "#after" do
    it "should allow adding after hooks to save" do
      obj = HooksSpecClass.new
      obj.save
      obj.after_hook.should == 'AFTER'
    end
    
    it "should allow adding after hooks to load" do
      HooksSpecClass.new.save
      HooksSpecClass.load("test")
      HooksSpecClass.after_load_hook.should == 'AFTER LOAD'
    end
    
    it "should allow adding after hooks to delete" do
      obj = HooksSpecClass.new
      obj.save
      obj.delete
      obj.after_delete_hook.should == 'AFTER DELETE'
    end
    
    it "should allow adding after hooks to clear!" do
      HooksSpecClass.new.save
      HooksSpecClass.clear!
      HooksSpecClass.after_clear_hook.should == 'AFTER CLEAR'
    end
  end
end