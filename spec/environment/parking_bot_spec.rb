# frozen_string_literal: true
require 'aws-sdk-sqs'

describe 'Given an environment running parking bot' do
  context 'When I query it' do
    %w(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY CREDIT_CARD_ID
       ZONE_NUMBER SPACE_NUMBER PHONE_NUMBER PIN).each do |required|
      example "Then #{required} is defined", :env_check do
        expect(ENV[required]).not_to be nil
      end
    end
  end
end

describe 'Given a queue for receiving verification codes from Passport' do
  context 'When I query it' do
    example 'Then it exists', :env_check do
      sqs_client = Aws::SQS::Client.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
      ppprk_codes_queue_url = sqs_client.get_queue_url(queue_name: 'ppprk-codes')
      expect(ppprk_codes_queue_url.queue_url).not_to be nil
    end
  end
end
