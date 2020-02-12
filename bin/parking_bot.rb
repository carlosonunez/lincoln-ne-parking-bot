#!/usr/bin/env ruby
$LOAD_PATH.unshift('./lib')
if Dir.exist? './vendor'
  $LOAD_PATH.unshift('./vendor/bundle/ruby/**gems/**/lib')
end

require 'parking_bot'
%w(app_account_ak app_account_sk aws_sqs_region).each do |required_secret|
  raise "Environment secret #{required_secret} not defined." \
    unless File.exist? "secrets/#{required_secret}"
end

ENV['AWS_ACCESS_KEY_ID'] = File.read('secrets/app_account_ak')
ENV['AWS_SECRET_ACCESS_KEY'] = File.read('secrets/app_account_sk')
ENV['AWS_REGION'] = File.read('secrets/aws_sqs_region')
@parking_bot = ParkingBot.new
@parking_bot.login!(phone_number: ENV['PHONE_NUMBER'],
                    pin: ENV['PIN'])
@parking_bot.pay_for_parking!(zone_number: ENV['ZONE_NUMBER'],
                             space: ENV['SPACE_NUMBER'],
                             card: ENV['CREDIT_CARD_ID'])
