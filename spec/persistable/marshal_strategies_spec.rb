require File.join(File.dirname(__FILE__), '..', 'spec_helper')

{
  Persistable::MarshalStrategies::JSON => "{\"name\":\"Andy Kent\",\"age\":25}",
  Persistable::MarshalStrategies::YAML => "--- \nname: Andy Kent\nage: 25\n",
  Persistable::MarshalStrategies::RubyMarshal => "BAh7ByIJbmFtZSIOQW5keSBLZW50IghhZ2VpHg==\n",
}.each do |strategy_class, converted_data|
  source_data = { 'name' => "Andy Kent", 'age' => 25 }
  
  describe strategy_class do
    before(:each) { @strategy = strategy_class.new }
    it "converts a hash to the storage format" do
      @strategy.to_storage(source_data).should == converted_data
    end
    
    it "converts from the storage format back to a hash" do
      @strategy.from_storage(converted_data).should == source_data
    end
  end
end