# frozen_string_literal: true

require 'spec_helper'

describe 'Given a message on a queue containing our verification code' do
  before(:each) do
    SpecHelpers::Aws::SQSLocal.start_mocking!
    @bot = ParkingBot.new
  end
  after(:each) do
    @bot = nil
  end

  context 'When we receive it' do
    example 'Then we get the code', :unit_with_queue do
      expect(@bot.fetch_latest_code).to eq 123
    end
  end
end
