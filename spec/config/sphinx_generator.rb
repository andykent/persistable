module SphinxGenerator
  class Config
    def self.setup(&blk)
      config = SphinxGenerator::Config.new
      config.instance_eval(&blk)
      config
    end
  
    def initialize
      @groups = []
    end
  
    def source(name, &blk)
      @groups << Source.new(name, &blk)
    end
  
    def index(name, &blk)
      @groups << Index.new(name, &blk)
    end
  
    def indexer(&blk)
      @groups << Indexer.new(&blk)
    end
  
    def searchd(&blk)
      @groups << Searchd.new(&blk)
    end
  
    def generate(file)
      save(file, output)
    end
    
    private
    
    def save(file, txt)
      File.open(file, 'w') {|f| f << txt }
    end
    
    def output
      output = %(# =================================
# Auto generated Sphinx config file
# =================================\n\n)
      output += @groups.map {|g| g.generate }.join("\n\n\n")
      output
    end
  end
  
  class Group
    def initialize(name, &blk)
      @name = name
      @params = []
      instance_eval(&blk)
    end
    
    def _type; 'UNDEFINED'; end
 
    def generate
      %(#{group_type} #{name_for_output}\n{\n#{params_for_output}\n})
    end
    
    private
    
    def method_missing(param, val)
      set_param(param, val)
    end
    
    def set_param(param, val)
      @params << [param, val]
    end
    
    def name_for_output
      @name
    end
    
    def params_for_output
      @params.map {|k,v| "  #{k.to_s.ljust(20)} = #{v}" }.join("\n")
    end
  end
  
  class UnamedGroup < Group
    def initialize(&blk)
      @params = []
      instance_eval(&blk)
    end
    
    def generate
      %(#{group_type}\n{\n#{params_for_output}\n})
    end
  end
  
  class Source < Group
    def initialize(name, &blk)
      @inherit_from = nil
      super
    end
    
    def group_type; 'source'; end
    
    def db_type(val) # we must use db_type as type is an inbuilt method
      set_param('type', val)
    end
    
    def name_for_output
      @inherit_from ? "#{@name} : #{@inherit_from}" : "#{@name}"
    end
    
    def inherit_from(name)
      @inherit_from = name
    end
  end
  
  class Index < Group
    def group_type; 'index'; end    
  end
  
  class Indexer < UnamedGroup
    def group_type; 'indexer'; end    
  end
  
  class Searchd < UnamedGroup
    def group_type; 'searchd'; end    
  end
end
 
class TrueClass
  def to_s
    '1'
  end
end
 
class FalseClass
  def to_s
    '0'
  end
end


SPHINX_CONFIG_PATH = File.expand_path(File.dirname(__FILE__))

SphinxGenerator::Config.setup do |c|
  
  #
  # BASE SOURCE
  #
  source :people do
    db_type 'xmlpipe2'
    xmlpipe_command "ruby #{File.join(SPHINX_CONFIG_PATH, 'sphinxpipe.rb')}"
  end
  
  index :people do
    source 'people_src'
    path 'persistable_specs_people_src'
    charset_type 'utf-8'
  end
  
  #
  # GLOBAL
  #
  indexer do
    mem_limit  '256M'
  end

  searchd do
    port 3312
    log  '/var/sphinx/log/searchd.log'
    query_log  '/var/sphinx/log/query.log'
    pid_file '/var/sphinx/log/searchd.pid'
  end
end.generate(File.join(SPHINX_CONFIG_PATH, 'sphinx.conf'))