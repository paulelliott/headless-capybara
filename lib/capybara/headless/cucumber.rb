require 'capybara/cucumber'
require 'capybara/headless'

Before('@headless') do
  Capybara.current_driver = :headless
end
