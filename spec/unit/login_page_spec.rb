# frozen_string_literal: true

require 'spec_helper'

# Some of these methods test whether an error is raised while others
# test for specific elements of the page existing. This is because
# of a design change during development that I haven't applied retroactively
# to older methods before it. I thought that it was more reliable to have
# a method fail if an element that should be on the page after doing a thing
# is not there instead of testing for it after the fact.
describe 'Given a parking bot' do
  before(:each) do
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/')
    allow(ParkingBot::SQSQueue).to receive(:new).and_return(nil)
    @bot = ParkingBot.new
  end
  after(:each) do
    @bot = nil
  end

  context 'When I visit the Welcome page' do
    example 'Then I can enter my number to start the login process',
            :unit_page do
      expect { @bot.send(:start_login!) }.not_to raise_error
    end
  end

  context 'When I enter my phone number' do
    example "Then I'm asked to enter a verification code", :unit_page do
      @bot.send(:start_login!)
      @bot.send(:provide_phone_number, 123)
      expect(@bot.session.has_field?('verificationCode')).to be true
    end
  end

  # The test for actually grabbing verification codes from text messages
  # is covered in spec/unit/verification_code_spec.rb
  context 'When I provide a verification code' do
    example 'Then I am logged in', :unit_page do
      @bot.send(:start_login!)
      @bot.send(:provide_phone_number, 123)
      @bot.send(:submit_verification_code, 123)
      expect(@bot.session.has_text?('Secure Login')).to be true
    end
  end

  context 'When I provide my PIN' do
    example 'Then I can start paying for parking', :unit_page do
      @bot.send(:start_login!)
      @bot.send(:provide_phone_number, 123)
      @bot.send(:submit_verification_code, 123)
      @bot.send(:provide_pin, 1234)
      zone_text = 'Enter the zone number posted at this location:'
      expect(@bot.session.has_content?('label', zone_text)).to be true
    end
  end
end
