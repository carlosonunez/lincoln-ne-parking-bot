# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'shoryuken'
require 'socket'

module SpecHelpers
  module Aws
    module SQSLocal
      def self.start_mocking!
        unless started?
          raise "Local SQS server not available; start it with \
docker-compose run --rm sqs"
        end
        create_mock_client do |client|
          configure_client(client)
          configure_server(client)
        end
      end

      def self.started?
        host = URI(ENV['AWS_SQS_ENDPOINT_URL']).host
        port = URI(ENV['AWS_SQS_ENDPOINT_URL']).port
        Socket.tcp(host, port, connect_timeout: 3) { true }
      rescue StandardError
        false
      end

      def self.configure_server(client)
        Shoryuken.configure_server do |config|
          config.sqs_client = client
        end
      end

      def self.configure_client(client)
        Shoryuken.configure_client do |config|
          config.sqs_client = client
        end
      end

      def self.create_mock_client
        %w[APP_AWS_SECRET_ACCESS_KEY
           APP_AWS_ACCESS_KEY_ID
           AWS_SQS_ENDPOINT_URL].each do |required_env_var|
          raise "Set #{required_env_var}" if ENV[required_env_var].nil?
        end
        yield(::Aws::SQS::Client.new(
          region: 'us-east-1',
          access_key_id: ENV['APP_AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['APP_AWS_SECRET_ACCESS_KEY'],
          endpoint: ENV['AWS_SQS_ENDPOINT_URL'],
          verify_checksums: false
        ))
      end

      private_class_method :create_mock_client
      private_class_method :configure_server
      private_class_method :configure_client
    end
  end
end
