# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'shoryuken'
require 'socket'

module SpecHelpers
  module Aws
    module SQSLocal
      @sqs_client = nil

      def self.start_mocking!
        check_env!
        unless started?
          raise "Local SQS server not available; start it with \
docker-compose run --rm sqs"
        end
        create_mock_client
        configure_client
        configure_server
      end

      def self.create_queue!(queue_name:)
        @sqs_client.create_queue(queue_name: queue_name)
      rescue StandardError
        raise "Unable to create queue: #{name}"
      end

      def self.push_test_message!(queue:, message:)
        Shoryuken::Client.queues(queue).send_message(message)
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

      def self.configure_server
        Shoryuken.configure_server do |config|
          config.sqs_client = @sqs_client
        end
      end

      def self.configure_client
        Shoryuken.configure_client do |config|
          config.sqs_client = @sqs_client
        end
      end

      def self.check_env!
        %w[AWS_REGION AWS_SQS_ENDPOINT_URL].each do |required_env_var|
          raise "Set #{required_env_var}" if ENV[required_env_var].nil?
        end
      end

      def self.create_mock_client
        @sqs_client ||= ::Aws::SQS::Client.new(
          region: ENV['AWS_REGION'],
          access_key_id: 'fake',
          secret_access_key: 'fake',
          endpoint: ENV['AWS_SQS_ENDPOINT_URL'],
          verify_checksums: false
        )
      end

      private_class_method :check_env!
      private_class_method :create_mock_client
      private_class_method :configure_server
      private_class_method :configure_client
    end
  end
end
