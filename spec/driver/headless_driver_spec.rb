require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::Headless do

  before do
    @driver = Capybara::Driver::Headless.new(TestApp)
  end

  it_should_behave_like "driver"
  it_should_behave_like "driver with javascript support"

end
