# frozen_string_literal: true

module SpecHelpers
  module TestMocks
    TEST_MOCKS_FILE = 'spec/include/mocks.yml'

    RSpec.configure do |config|
      config.before(:all, integration: true) do
        $api_gateway_url ||= Helpers::Integration::HTTP.fetch_endpoint
        if $api_gateway_url.nil? || $api_gateway_url.empty?
          raise "Please define API_GATEWAY_URL as an environment variable or \
    run 'docker-compose run --rm integration-setup'"
        end
        $test_api_key =
          Helpers::Integration::SharedSecrets.read(secret_name: 'api_key')
        raise 'Please create the "api_key" secret.' if $test_api_key.nil?
      end
    end

    def self.generate!
      extend RSpec::Mocks::ExampleMethods
      fetch_mocks.each do |mock|
        allow(HTTParty)
          .to receive(:get)
          .with(mock[:url], follow_redirects: false)
          .and_return(double(HTTParty::Response,
                             code: 200,
                             body: File.read("spec/fixtures/#{mock[:page]}")))
      end
    end

    def self.generate_mock_session!(url)
      extend RSpec::Mocks::ExampleMethods
      raise "No mock for #{url} in #{TEST_MOCKS_FILE}" if find_mock(url).nil?

      mocked_page_path = find_mock(url)[:page]
      register_test_driver
      mock_session = Capybara::Session.new :selenium_test
      mock_session.visit("file:///app/spec/fixtures/#{mocked_page_path}")
      enable_mocked_session! mock_session
      mock_visits! url
    end

    def self.end_mock_session!(session)
      session.quit
    end

    def self.enable_mocked_session!(session)
      extend RSpec::Mocks::ExampleMethods

      allow(Capybara::Session).to receive(:new) { :failure }
      allow(Capybara::Session)
        .to receive(:new)
        .with(:selenium_test)
        .and_return(session)
      allow(Capybara::Session)
        .to receive(:new)
        .with(:selenium)
        .and_return(session)
    end

    def self.mock_visits!(url)
      allow_any_instance_of(Capybara::Session).to receive(:visit) { :failure }
      allow_any_instance_of(Capybara::Session)
        .to receive(:visit)
        .with(url)
        .and_return('status' => 'success')
    end

    def self.fetch_mocks
      YAML.safe_load(File.read(TEST_MOCKS_FILE), symbolize_names: true)
    end

    def self.find_mock(url)
      fetch_mocks.find { |key| key[:url] == url }
    end

    def self.register_test_driver
      if ENV['USE_POLTERGEIST'] == true
        Capybara.register_driver :poltergeist_test do |app|
          poltergeist_path = ENV['POLTERGEIST_PATH'] ||
                             '/opt/phantomjs/phantomjs'
          raise 'Poltergeist not found' unless File.exist? poltergeist_path

          Capybara::Poltergeist::Driver.new(app,
                                            phantomjs: poltergeist_path,
                                            js_errors: false,
                                            phantomjs_options: [
                                              '--ssl-protocol=any',
                                              '--load-images=no',
                                              '--ignore-ssl-errors=yes'
                                            ])
        end
      else
        capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
          'chromeOptions' => {
            'args' => ['--no-default-browser-check']
          }
        )
        Capybara.register_driver :selenium_test do |app|
          Capybara::Selenium::Driver.new(app,
                                         browser: :remote,
                                         url: 'http://selenium:4444/wd/hub',
                                         desired_capabilities: capabilities)
        end
      end
    end
  end
end
