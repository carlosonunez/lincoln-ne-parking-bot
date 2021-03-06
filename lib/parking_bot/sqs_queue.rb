# frozen_string_literal: true

require 'aws-sdk-sqs'

class ParkingBot
  class SQSQueue
    def initialize(queue_name:)
      @queue_name = queue_name
      @client = create
      @queue_url = queue_url
    end

    def pop!
      raise 'Queue not ready' unless ready?

      messages = @client.receive_message(
        queue_url: queue_url,
        wait_time_seconds: 20
      ).messages
      desired_message = messages.first
      return nil if desired_message.nil?

      message_body = desired_message.body
      @client.delete_message(
        queue_url: queue_url,
        receipt_handle: desired_message.receipt_handle
      )
      message_body
    end

    def queue_url
      @client.get_queue_url(queue_name: @queue_name).queue_url
    end

    private

    def create
      ::Aws::SQS::Client.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        verify_checksums: false
      )
    end

    def ready?
      !queue_url.nil?
    end
  end
end
