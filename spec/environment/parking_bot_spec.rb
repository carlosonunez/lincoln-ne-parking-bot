# frozen_string_literal: true

require 'aws-sdk-sqs'

describe 'Given an environment running parking bot' do
  context 'When I query it' do
    %w[CREDIT_CARD_ID ZONE_NUMBER SPACE_NUMBER PHONE_NUMBER PIN].each do |required|
      example "Then #{required} is defined", :env_check do
        expect(ENV[required]).not_to be nil
      end
    end

    %w[app_account_ak app_account_sk aws_sqs_region].each do |output|
      example "And Terraform stored output #{output} locally", :env_check do
        expect(File.exist?("/app/secrets/#{output}")).to be true
      end
    end
  end
end

describe 'Given a queue for receiving verification codes from Passport' do
  context 'When I query it' do
    example 'Then it exists', :env_check do
      sqs_client = Aws::SQS::Client.new(
        region: File.read('/app/secrets/aws_sqs_region'),
        access_key_id: File.read('/app/secrets/app_account_ak'),
        secret_access_key: File.read('/app/secrets/app_account_sk')
      )
      ppprk_codes_queue_url = sqs_client.get_queue_url(queue_name: 'ppprk-codes')
      expect(ppprk_codes_queue_url.queue_url).not_to be nil
    end
  end
end
