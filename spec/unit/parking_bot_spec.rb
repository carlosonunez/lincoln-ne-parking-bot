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
    before(:each) do
      @bot.login!(phone_number: '123', pin: '1234')
    end

    example 'Then I am logged in', :unit do
      expect(@bot.logged_in?).to be true
    end

    example 'And I am able to pay for parking', :unit do
      expect do
        @bot.pay_for_parking!(zone_number: 123,
                              space: 1234,
                              card: 'TestCard-1234')
      end
        .not_to raise_error
    end
  end
end
