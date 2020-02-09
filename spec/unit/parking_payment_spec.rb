# frozen_string_literal: true

require 'spec_helper'

describe 'Given a parking bot that is logged in' do
  before(:each) do
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/')

    # TODO: Replace with login! when it becomes available.
    @bot = ParkingBot.new
    @bot.start_login!
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

  context 'When I enter a space ID' do
    example 'Then I am asked for a length of time to pay', :unit do
      @bot.provide_zone(123)
      expect { @bot.provide_space(1234) }.not_to raise_error
    end
  end

  # When I wrote this, I always selected the max amount of time available.
  # The idea behind this was to be able to pay for parking overnight
  # without having to wake up at 8am when the meters began collecting.
  # The only way to specify an arbitrary amount of time is to use a
  # grid picker to increase time to park in 15 minute increments.
  # I didn't want to do this.
  context 'When I select the maximum amount of time available' do
    example 'Then I am asked to pay', :unit do
      @bot.provide_zone(123)
      @bot.provide_space(456)
      expect { @bot.choose_max_parking_time! }.not_to raise_error
    end
  end

  context 'When I select a card to pay with (that I added previously)' do
    example 'Then I have a parking space!', :unit do
      @bot.provide_zone(123)
      @bot.provide_space(456)
      @bot.choose_max_parking_time!
      expect { @bot.pay!(card: 'TestCard-1234') }.not_to raise_error
    end
  end
end
