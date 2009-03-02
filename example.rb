require "lib/persistable"
require "digest/sha1"

class Person
  include Persistable
  
  # use :storage_engine, StorageEngines::TokyoCabinetHashDB.new('person.tch')
  
  def initialize(attributes)
    @attributes = attributes
  end
  
  def to_hash
    @attributes
  end
  
  def key
    @attributes['name']
  end
  
  def name
    @attributes['name']
  end
  
  def email
    @attributes['email']
  end
end

if Person.new('name' => "Andy", 'email' => 'andy.kent@me.com').save
  puts Person.load("Andy").email
end

Person.each {|k, p| puts "#{p.name} (#{p.email})" }

puts Person.count






class Product
  include Persistable
  
  # use :storage_engine, StorageEngines::TokyoCabinetHashDB.new('demo.tch')
  use :storage_engine, StorageEngines::FileSystem.new(File.dirname(__FILE__)+'/tmp')
  use :marshal_strategy, MarshalStrategies::JSON.new
  use :key do
    Digest::SHA1.hexdigest(@url)
  end
  
  attr_reader :name, :url
  
  use :save do
    { 'name' => @name, 'url' => @url }
  end
  
  use :load do |data|
    Product.new(data['name'], data['url'])
  end
  
  def initialize(name, url)
    @name, @url = name, url
  end
end


if Product.new("Test Product", "http://www.google.com/1").save
  sha1 = Digest::SHA1.hexdigest("http://www.google.com/1")
  puts Product.load(sha1).name
end





# def run_benchmark(n, strategy)
#   Product.use :marshal_strategy, strategy.new
#   n.times do
#     url = rand.to_s 
#     Product.new("Test", url).save
#     Product.load(Digest::SHA1.hexdigest(url))
#   end
# end
# 
# require "benchmark"
# Benchmark.bmbm(10) do |x|
#   x.report("YAML") { run_benchmark(25_000, Persistable::MarshalStrategies::YAML) }
#   x.report("JSON") { run_benchmark(25_000, Persistable::MarshalStrategies::JSON) }
#   x.report("Marshal") { run_benchmark(25_000, Persistable::MarshalStrategies::RubyMarshal) }
# end