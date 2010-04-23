require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Capybara::Driver::Headless do
  before do
    @session = Capybara::Session.new(:headless, TestApp)
  end

  describe '#driver' do
    it "should be a headless driver" do
      @session.driver.should be_an_instance_of(Capybara::Driver::Headless)
    end
  end

  describe '#mode' do
    it "should remember the mode" do
      @session.mode.should == :headless
    end
  end

  it_should_behave_like "session"
  it_should_behave_like "session with javascript support"
  it_should_behave_like "session with headers support"

end
