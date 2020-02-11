# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'socket'

module SpecHelpers
  module Aws
    module SQSLocal
      def self.create_mock_client
        raise 'Endpoint not defined' if ENV['AWS_SQS_ENDPOINT_URL'].nil?

        unless started?
          raise "Local SQS server not available; start it with \
docker-compose run --rm sqs"
        end
        ::Aws::SQS::Client.new(
          region: 'us-east-1',
          access_key_id: 'fake',
          secret_access_key: 'fake',
          endpoint: ENV['AWS_SQS_ENDPOINT_URL'],
          verify_checksums: false
        )
      end

      def self.create_queue!(client:, queue_name:)
        client.create_queue(queue_name: queue_name)
      rescue StandardError
        raise "Unable to create queue: #{name}"
      end

      def self.push_test_message!(client:, queue:, message:)
        queue_url = client.get_queue_url(queue_name: queue).queue_url
        client.send_message(queue_url: queue_url,
                            message_body: message)
      rescue StandardError
        raise 'Unable to queue test message (did you create the queue)?'
      end

      def self.started?
        host = URI(ENV['AWS_SQS_ENDPOINT_URL']).host
        port = URI(ENV['AWS_SQS_ENDPOINT_URL']).port
        Socket.tcp(host, port, connect_timeout: 3) { true }
      rescue StandardError
        false
      end

      private_class_method :started?
    end
  end
end
