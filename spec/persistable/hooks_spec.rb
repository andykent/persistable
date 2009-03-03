require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class HooksSpecClass
  include Persistable
  class << self; attr_reader :before_load_hook, :after_load_hook end
  attr_reader :before_hook, :after_hook
  before_instance_method(:save) { @before_hook = 'BEFORE' }
  after_instance_method(:save) { @after_hook = "AFTER" }
  
  before_class_method(:load) { @before_load_hook = "BEFORE LOAD" }
  
  def initialize(args={}) end
  def key; 'test' end
  def to_hash; {} end
end

describe "Hooks" do
  describe "#before" do
    it "should allow adding before hooks to instance methods" do
      klass = HooksSpecClass.new
      klass.save
      klass.before_hook.should == 'BEFORE'
    end

    it "should allow adding after hooks to class methods" do
      HooksSpecClass.new.save
      HooksSpecClass.load("test")
      HooksSpecClass.before_load_hook.should == 'BEFORE LOAD'
    end
  end
  
  describe "#after" do
    it "should allow adding after hooks to instance methods" do
      klass = HooksSpecClass.new
      klass.save
      klass.after_hook.should == 'AFTER'
    end
    
    it "should allow adding after hooks to class methods" do
      pending
    end
  end
end