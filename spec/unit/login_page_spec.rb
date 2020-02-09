# frozen_string_literal: true

require 'spec_helper'

describe 'Given a parking bot' do
  before(:each) do
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/')
    @bot = ParkingBot.new
  end
  after(:each) do
    @bot = nil
  end

  context 'When I visit the Welcome page' do
    example 'Then I can enter my number to start the login process', :unit do
      expect { @bot.start_login! }.not_to raise_error
    end
  end

  context 'When I enter my phone number' do
    example "Then I'm asked to enter a verification code", :unit do
      @bot.start_login!
      @bot.provide_phone_number(123)
      expect(@bot.session.has_field?('verificationCode')).to be true
    end
  end

  # The test for actually grabbing verification codes from text messages
  # is covered in spec/unit/verification_code_spec.rb
  context 'When I provide a verification code' do
    example 'Then I am logged in', :unit do
      @bot.start_login!
      @bot.provide_phone_number(123)
      @bot.submit_verification_code(123)
      expect(@bot.session.has_text?('Secure Login')).to be true
    end
  end

  context 'When I provide my PIN' do
    example 'Then I can start paying for parking', :unit do
      @bot.start_login!
      @bot.provide_phone_number(123)
      @bot.submit_verification_code(123)
      @bot.provide_pin(1234)
      zone_text = 'Enter the zone number posted at this location:'
      expect(@bot.session.has_content?('label', zone_text)).to be true
    end
  end

  context 'When I log in' do
    # I can't do this one until I set up a pub-sub for getting verification
    # codes.
    example 'Then I am logged in', :wip do
      @bot.login!(phone_number: 1_234_567_890, pin: 1234)
      zone_text = 'Enter the zone number posted at this location:'
      expect(@bot.session.has_content?('label', zone_text)).to be true
    end
  end
end
