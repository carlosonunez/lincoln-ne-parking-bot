# frozen_string_literal: true

module SpecHelpers
  module Service
    def self.get(endpoint, params: {}, authenticated: false)
      yield(request(:get, endpoint, params, authenticated))
    end

    def self.post(endpoint, params: {}, authenticated: false)
      yield(request(:post, endpoint, params, authenticated))
    end

    def self.request(method, endpoint, params, authenticated)
      raise 'API endpoint not found; run TestMocks.generate first' \
        if $api_gateway_url.nil?

      headers = {}
      headers['x-api-key'] = $test_api_key if authenticated

      httparty = HTTParty
      uri = [$api_gateway_url, endpoint].join('/')
      httparty.send(method.to_sym, uri, headers: headers, query: params)
    end

    private_class_method :request
  end
end
