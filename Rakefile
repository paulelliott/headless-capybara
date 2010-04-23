require 'rubygems'

gem 'hoe', '2.6'
require 'hoe'

Hoe.plugin 
Hoe.plugin :debugging, :doofus, :git
Hoe.plugins.delete :rubyforge

Hoe.spec 'capybara-headless' do
  developer 'Paul Elliott', 'paul@hashrocket.com'
  self.version = "0.0.1"

  self.readme_file      = 'README.rdoc'
  self.extra_rdoc_files = Dir['*.rdoc']

  self.extra_deps = [
    ['capybara', '0.3.7'],
    ['harmony', '0.5.5']
  ]

  self.extra_dev_deps = [
    ['rack-test', '>= 0.5.3'],
    ['rspec', '>= 1.3.0']
  ]
end
