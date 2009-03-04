module Persistable
  module SphinxSearchable
    def self.included(receiver)
      require "riddle"
      receiver.extend(ClassMethods)
    end
    
    module ClassMethods
      def xml_pipe(index, io)
        io << %(<?xml version="1.0" encoding="utf-8"?> <sphinx:docset> #{sphinx_indexes[index].xml_schema})
        self.each do |key, doc|
          io << sphinx_indexes[index].xml_document(doc)
        end
        io << %(</sphinx:docset>)
      end
      
      def sphinx_index(name, &blk)
        sphinx_indexes[name] = SphinxIndex.new(self, name, &blk)
      end
      
      def search(index, query, opts={})
        sphinx_indexes[index].search(query, opts)
      end
      
      def sphinx_indexes
        @sphinx_indexes ||= {}
      end
    end
    
    class SphinxIndex
      def initialize(klass, index_name, &blk)
        @klass = klass
        @index_name = index_name
        @fields = []
        @attributes = []
        @sphinx_options = {}
        @guid = nil
        instance_eval(&blk)
      end
      
      def search(query, opts={})
        opts = @sphinx_options.merge(opts)
        client = Riddle::Client.new
        filters = opts.delete(:filters)
        filters.each do |attribute, values|
          values = [values] unless values.is_a?(Array)
          client.filters << Riddle::Client::Filter.new(attribute.to_s, values)
        end unless filters.nil?
        opts.each {|option, value| client.send(:"#{option}=", value) }
        results = client.query(query, @index_name.to_s)
        docids = results[:matches].map {|m| m[:doc]}
        { :results => @klass.load_batch_via_index(@docid, docids), :total => results[:total_found] }
      end
      
      def docid(name)
        @docid = name
      end
      
      def field(name)
        @fields << name
      end
      
      def attribute(name, type, opts={})
        @attributes << opts.merge(:name => name, :type => type)
      end
      
      def set(key, val)
        @sphinx_options[key.to_sym] = val
      end
      
      def xml_schema
        %(<sphinx:schema> #{xml_field_list} #{xml_attribute_list} </sphinx:schema>)
      end
      
      def xml_document(doc)
         %(<sphinx:document id="#{doc.send(@docid)}"> #{xml_fields(doc)} #{xml_attributes(doc)} </sphinx:document>)
      end
      
      private
      
      def xml_fields(doc)
        @fields.map {|f| %(<#{f.to_s}><![CDATA[#{doc.send(f.to_sym)}]]></#{f.to_s}>) }.join(' ')
      end
      
      def xml_attributes(doc)
        @attributes.map { |a| %(<#{a[:name].to_s}>#{doc.send(a[:name].to_sym)}</#{a[:name].to_s}>) }.join(' ')
      end
      
      def xml_field_list
        @fields.map {|f| %(<sphinx:field name="#{f.to_s}"/>) }.join(" ")
      end
      
      def xml_attribute_list
        @attributes.map do |a|
          attrs = a.map { |k,v| %(#{k.to_s}="#{v.to_s}") }.join(' ') 
          %(<sphinx:attr #{attrs} />) 
        end.join(" ")
      end
    end
  end
end