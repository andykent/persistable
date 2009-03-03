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
        all_files.each do |file|
          key = file.match(/#{@dir}\/(.+?)\.txt/)[1]
          yield(key, read(key))
        end
      end
      
      def count
        all_files.length
      end
      
      def clear!
        FileUtils.rm_rf(@dir)
        FileUtils.mkdir_p(@dir)
        true
      end

      private

      def file(k)
        File.join(@dir, "#{k}.txt")
      end
      
      def all_files
        Dir[@dir+'/*.txt']
      end
    end
  end
end