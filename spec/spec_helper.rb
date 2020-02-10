# frozen_string_literal: true

require 'capybara'
require 'capybara/poltergeist'
require 'json'
require 'yaml'
require 'parking_bot'

Dir.glob('/app/spec/helpers/**/*.rb') do |file|
  require_relative file
end

RSpec.configure do |config|
  config.before(:all, unit_with_database: true) do
    ENV['APP_AWS_ACCESS_KEY_ID'] = 'fake'
    ENV['APP_AWS_SECRET_ACCESS_KEY'] = 'fake'
    unless $dynamodb_mocking_started
      SpecHelpers::Aws::DynamoDBLocal.start_mocking!
      puts 'Waiting 60 seconds for local DynamoDB instance to become availble.'
      seconds_elapsed = 0
      loop do
        raise 'DynamoDB local not ready.' if seconds_elapsed == 60
        break if SpecHelpers::Aws::DynamoDBLocal.started?

        seconds_elapsed += 1
        sleep(1)
      end
      $dynamodb_mocking_started = true
    end
  end

  config.before(:all, unit_with_queue: true) do
    ENV['APP_AWS_ACCESS_KEY_ID'] = 'fake'
    ENV['APP_AWS_SECRET_ACCESS_KEY'] = 'fake'
    unless $sqs_mocking_started
      SpecHelpers::Aws::SQSLocal.start_mocking!
      $sqs_mocking_started = true
    end
  end

  config.after(:each, unit_with_database: true) do
    SpecHelpers::Aws::DynamoDBLocal.drop_tables!
  end
end
