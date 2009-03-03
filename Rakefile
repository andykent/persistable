require 'rubygems'
 
task :default => :spec
 
# =========
# = RSPEC =
# =========
 
begin
  require 'spec/rake/spectask'
  desc "Run all specs"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w{-f s -c -L mtime}
  end
rescue LoadError => e
  puts "RSpec gem not found"
end