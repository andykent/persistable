require File.join(File.dirname(__FILE__), 'person')

PersonSearchableSpecClass.new('name' => "Andy", 'email' => 'andy.kent@me.com', 'age' => 25, 'guid' => 123).save!
PersonSearchableSpecClass.new('name' => "Mike", 'email' => 'mike.jones@trafficbroker.co.uk', 'age' => 31, 'guid' => 456).save!

PersonSearchableSpecClass.xml_pipe(:people, $stdout)