require 'capybara'
require 'capybara/driver/headless_driver'

if Object.const_defined? :Cucumber
  require 'capybara/headless/cucumber'
end
