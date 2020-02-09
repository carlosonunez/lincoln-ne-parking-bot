# frozen_string_literal: true

require 'spec_helper'

describe 'Given a parking bot that is logged in' do
  before(:each) do
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/#verify')

    # TODO: Replace with login! when it becomes available.
    @bot = ParkingBot.new
    @bot.go_to_verification_page!
    @bot.provide_phone_number(123)
    @bot.submit_verification_code(123)
    @bot.provide_pin(1234)
  end
  after(:each) do
    @bot = nil
  end

  context 'When I enter a zone number' do
    example 'Then I am asked to enter a space number', :unit do
      expect { @bot.provide_zone(123) }.not_to raise_error
    end
  end
end
