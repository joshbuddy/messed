libdir = File.expand_path("lib")
$:.unshift(libdir) unless $:.include?(libdir)

require 'messed'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "messed"
    s.description = s.summary = "A framework for short message paradigms"
    s.email = "joshbuddy@gmail.com"
    s.homepage = "http://github.com/joshbuddy/messed"
    s.authors = ["Joshua Hull"]
    s.files = FileList["[A-Z]*", "{lib,spec,bin,application_spec,patterns}/**/*"]
    s.add_dependency 'eventmachine'
    s.add_dependency 'em-http-request', '>=0.2.6'
    s.add_dependency 'em-beanstalk', '>=0.0.6'
    s.add_dependency 'hashify', '>=0.0.2'
    s.add_dependency 'hwia', '>=1.0.2'
    s.add_dependency 'twitter-stream', '>=0.1.3'
    s.add_dependency 'activesupport'
    s.add_dependency 'dressmaker', '>=0.0.3'
    s.add_dependency 'beanstalk-client'
    s.add_dependency 'rspec'
    s.add_dependency 'json'
    s.add_dependency 'thor'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'spec'
require 'spec/rake/spectask'
task :spec => ['spec:all', 'spec:application']
namespace(:spec) do
  Spec::Rake::SpecTask.new(:all) do |t|
    t.spec_opts ||= []
    t.spec_opts << "-rubygems"
    t.spec_opts << "--options" << "spec/spec.opts"
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:application) do |t|
    ENV['MESSED_HOME'] = '..'
    t.ruby_opts ||= []
    t.ruby_opts << '-Capplication_spec'
    t.spec_opts ||= []
    t.spec_opts << "-rubygems"
    t.spec_opts << "--options" << "spec/spec.opts"
    t.spec_files = FileList['application_spec/spec/**/*_spec.rb'].map{|f| f[/application_spec\/(.*)/, 1]}
  end

end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('spec_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

require 'rake/rdoctask'
desc "Generate documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'rdoc'
end

begin
  require 'code_stats'
  CodeStats::Tasks.new
rescue LoadError
  puts "Code stats not available, install it with gem install code_stats"
end
