module Persistable
  module StorageEngines
    class FileSystem
      def initialize(dir=Dir.pwd)
        require "fileutils"
        @dir = dir
        FileUtils.mkdir_p(@dir)
      end

      def read(k)
        File.read(file(k))
      end

      def write(k,v)
        File.open(file(k), 'w') {|f| f << v }
      end
      
      def each
        raise Persistable::NotImplemented
      end
      
      def count
        raise Persistable::NotImplemented
      end

      private

      def file(k)
        File.join(@dir, "#{k}.txt")
      end
    end
  end
end
