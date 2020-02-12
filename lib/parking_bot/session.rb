# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'

class ParkingBot
  module Session
    def self.create
      register_driver
      Capybara::Session.new :selenium
    end

    def self.register_driver
      %w[SELENIUM_HOST SELENIUM_PORT].each do |required|
        raise "Please define #{required}" if ENV[required].nil?
      end
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
        'chromeOptions' => {
          'args' => ['--no-default-browser-check']
        }
      )
      Capybara.register_driver :selenium do |app|
        Capybara::Selenium::Driver.new(app,
                                       browser: :remote,
                                       url: hub_url,
                                       desired_capabilities: capabilities)
      end
      Capybara.javascript_driver = :selenium
      Capybara.default_driver = :selenium
    end

    def self.hub_url
      Socket.tcp(ENV['SELENIUM_HOST'], ENV['SELENIUM_PORT']) { true }
      "http://#{ENV['SELENIUM_HOST']}:#{ENV['SELENIUM_PORT']}/wd/hub"
    rescue IOError
      raise 'Selenium hub not started.'
    end

    private_class_method :register_driver
    private_class_method :hub_url
  end
end
