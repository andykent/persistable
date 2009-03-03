require File.join(File.dirname(__FILE__), '..', 'spec_helper')

require File.join(File.dirname(__FILE__), '..', 'config', 'person')

describe Persistable::SphinxSearchable do
  describe "#xml_pipe" do
    it "takes an index and IO stream and outputs a sphinx xmlpipe2 compatible stream" do
      PersonSearchableSpecClass.new('name' => "Andy", 'email' => 'andy.kent@me.com', 'age' => 25, 'guid' => 123).save!
      io = StringIO.new
      PersonSearchableSpecClass.xml_pipe(:people, io)
      io.string.should == %(<?xml version=\"1.0\" encoding=\"utf-8\"?> <sphinx:docset> <sphinx:schema> <sphinx:field name=\"name\"/> <sphinx:field name=\"email\"/> <sphinx:attr type=\"int\" name=\"age\" /> </sphinx:schema><sphinx:document id=\"123\"> <name><![CDATA[Andy]]></name> <email><![CDATA[andy.kent@me.com]]></email> <age>25</age> </sphinx:document></sphinx:docset>)
    end
  end
  
  describe "#sphinx_search" do
    before :all do
      config_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'sphinx.conf'))
      system "indexer --config #{config_path}"
      system "searchd -c #{config_path}"
      
      PersonSearchableSpecClass.new('name' => "Andy", 'email' => 'andy.kent@me.com', 'age' => 25, 'guid' => 123).save!
      PersonSearchableSpecClass.new('name' => "Mike", 'email' => 'mike.jones@trafficbroker.co.uk', 'age' => 31, 'guid' => 456).save!
    end
    
    after :all do
      system "searchd --stop"
    end
    
    it "should use riddle to search the sphinx index given" do
      PersonSearchableSpecClass.search(:people, "andy", :match_mode => :any)[:results].first.email.should == 'andy.kent@me.com'   
    end
  end
end