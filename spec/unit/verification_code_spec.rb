# frozen_string_literal: true

require 'spec_helper'

describe 'Given a message on a queue containing our verification code' do
  before(:each) do
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
  after(:each) do
    @bot = nil
  end

  context 'When we receive it' do
    example 'Then we get the code', :unit_page do
      expect(@bot.fetch_latest_code).to eq 804
    end
  end
end
