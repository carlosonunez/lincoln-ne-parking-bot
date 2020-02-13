# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'

module ::Selenium::WebDriver::Remote
  class Bridge
    alias old_execute execute

    # This slows down typing so that we don't get wrecked by the runner
    # moving too quickly.
    def execute(*args)
      sleep(rand(0.1..0.3).round(2))
      old_execute(*args)
    end
  end
end

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
      Capybara.default_max_wait_time = 10 # fucking animations
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
