# frozen_string_literal: true

require 'spec_helper'

describe 'Given a parking bot' do
  before(:each) do
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/#verify')
    @bot = ParkingBot.new
  end

  context 'When I visit the verification page' do
    before(:each) do
      @bot.go_to_verification_page!
    end

    example 'Then I can enter my phone number', :unit do
      text_me_button = @bot.session.find(:xpath,
                                         "//button[contains(text(), 'Text Me')]")
      phone_number_field = @bot.session.find(:xpath,
                                             "//input[@id='regPhoneNo']")
      require 'pry'; binding.pry
      expect(text_me_button.text).to eq 'Text Me'
      expect(phone_number_field).not_to be_nil
    end
  end
end
