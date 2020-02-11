# frozen_string_literal: true

require 'spec_helper'

describe 'Given a parking bot' do
  before(:each) do
    SpecHelpers::TestMocks.generate_mock_session!('https://ppprk.com/park/')
    @mock_client = SpecHelpers::Aws::SQSLocal.create_mock_client
    SpecHelpers::Aws::SQSLocal.create_queue!(client: @mock_client,
                                             queue_name: 'ppprk-codes')
    SpecHelpers::Aws::SQSLocal.push_test_message!(
      client: @mock_client,
      queue: 'ppprk-codes',
      message: File.read('spec/include/test_sqs_message.json')
    )
    allow(::Aws::SQS::Client).to receive(:new).and_return(@mock_client)
    @bot = ParkingBot.new
  end

  context 'When I login' do
    example 'Then I am logged in', :unit do
      @bot.login!(phone_number: '3477627147', pin: '7450')
      expect(@bot.logged_in?).to be true
    end
  end
end
