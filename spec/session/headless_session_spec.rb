require 'spec_helper'

describe Capybara::Session do
  context 'with a headless driver' do

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

    describe '#fill_in' do
      context 'with a nil value' do
        before do
          @session.visit('/form')
          @session.fill_in 'Name', :with => nil
          @session.click_button('awesome')
        end

        it 'sets the value to an empty string' do
          extract_results(@session)['Name'].should be_nil
        end
      end
    end

  end
end
