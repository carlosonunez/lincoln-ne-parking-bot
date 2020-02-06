# frozen_string_literal: true

require 'spec_helper'

describe 'Given a parking bot' do
  before(:each) do
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/#verify')
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/#mobileVerification')
    @bot = ParkingBot.new
  end
  after(:each) do
    @bot = nil
  end

  context 'When I visit the verification page' do
    example 'Then I can enter my phone number', :unit do
      @bot.go_to_verification_page!
      text_me_button =
        @bot.session.find(:xpath, "//button[contains(text(), 'Text Me')]")
      phone_number_field =
        @bot.session.find(:xpath, "//input[@id='regPhoneNo']")
      expect(text_me_button.text).to eq 'Text Me'
      expect(phone_number_field).not_to be_nil
    end
  end

  context 'When I enter my phone number' do
    example "Then I'm asked to enter a verification code", :unit do
      @bot.provide_phone_number(123)
      verification_code_field =
        @bot.session.find(:xpath, "//input[@id='verificationCode']")
      expect(verification_code_field).not_to be_nil
    end
  end
end
