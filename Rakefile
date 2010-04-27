require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "headless-capybara"
    gem.summary = "Javascript-enabled Capybara driver with no head!"
    gem.description = "Javascript-enabled Capybara driver with no head!"
    gem.email = "paul@hashrocket.com"
    gem.homepage = "http://github.com/paulelliott/headless-capybara"
    gem.authors = ["Paul Elliott","Robert Pitts"]

    gem.add_dependency "capybara", '0.3.7'
    gem.add_dependency 'johnson', '2.0.0.pre3'
    gem.add_dependency 'envjs', '0.3.4'

    gem.add_development_dependency "sinatra"
    gem.add_development_dependency "rspec", '1.3.0'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec
