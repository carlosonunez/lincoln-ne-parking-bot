# frozen_string_literal: true

require 'net/http'

module SpecHelpers
  module Integration
    module HTTP
      def self.fetch_endpoint
        until timed_out?(attempts ||= 1)
          endpoint_name = fetch_endpoint_name
          break unless endpoint_name.nil?

          attempts += 1
          sleep 1
        end
        raise 'Endpoint not found' if endpoint_name.nil?

        endpoint_name
      end

      def self.fetch_endpoint_name
        return ENV['API_GATEWAY_URL'] unless ENV['API_GATEWAY_URL'].nil?

        Helpers::Integration::SharedSecrets.read(secret_name: 'endpoint_name')
      end

      def self.timed_out?(seconds_elapsed)
        seconds_elapsed == (ENV['API_GATEWAY_URL_FETCH_TIMEOUT'] || 60)
      end
    end
  end
end
