# frozen_string_literal: true

require 'capybara'
require 'capybara/poltergeist'

class ParkingBot
  module Session
    def self.create
      register_driver
      Capybara::Session.new :poltergeist
    end

    def self.register_driver
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app,
                                          phantomjs: '/opt/phantomjs/phantomjs',
                                          js_errors: false,
                                          phantomjs_options: [
                                            '--ssl-protocol=any',
                                            '--load-images=no',
                                            '--ignore-ssl-errors=yes'
                                          ])
      end
    end

    private_class_method :register_driver
  end
end
