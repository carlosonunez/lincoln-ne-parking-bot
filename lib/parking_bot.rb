# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'base64'
require 'mail'
require 'parking_bot/session'
require 'parking_bot/constants'
require 'parking_bot/sqs_queue'

class ParkingBot
  attr_accessor :session

  def initialize
    @session = Session.create
    @queue = SQSQueue.new(queue_name: 'ppprk-codes')
    @logged_in = false
  end

  def login!(phone_number:, pin:)
    start_login!
    provide_phone_number(phone_number)
    verification_code = fetch_latest_code
    submit_verification_code(verification_code)
    provide_pin(pin)
    @logged_in = true
  end

  def logged_in?
    @logged_in
  end

  def pay_for_parking!(zone_number:, space:, card:)
    raise 'Log in first' unless logged_in?

    provide_zone(zone_number)
    provide_space(space)
    choose_max_parking_time!
    pay!(card: card)
  end

  private

  def start_login!
    @session.visit(Constants::URL::LOGIN)
    @session.click_link('Get Started')
    raise 'Unable to start the login process' \
      unless @session.has_button?('Text Me') &&
             @session.has_field?('regPhoneNo')
  end

  def provide_phone_number(phone_number)
    @session.fill_in('regPhoneNo', with: phone_number)
    @session.click_button('Text Me')
    @session.click_button('Yes')
  rescue StandardError
    raise 'Failed to provide phone number'
  end

  def fetch_latest_code
    email_notification = @queue.pop!
    raise 'Timed out while waiting for a code.' if email_notification.nil?

    encoded_email = JSON.parse(email_notification)['content']
    find_code_in_email(encoded_email)
  end

  def submit_verification_code(code)
    @session.fill_in('verificationCode', with: code)
    @session.click_button('Verify')
    @session.click_button('Ok')
  rescue StandardError
    raise 'Failed to provide verification code or verification code incorrect.'
  end

  def provide_pin(pin)
    @session.fill_in('pin', with: pin)
    @session.click_button('Sign In')
    raise 'PIN not valid' if @session.has_text?(Constants::Errors::INVALID_PIN)
  rescue StandardError
    raise 'Something went wrong'
  end

  def find_code_in_email(encoded_email)
    email = Mail.read_from_string(Base64.decode64(encoded_email))
    email.body.raw_source.split("\r\n").map do |line|
      if line.match(/^Your Passport.* \d{3}$/)
        line.gsub(/.*(\d{3})$/, '\1').to_i
      end
    end.compact!.first
  end

  def provide_zone(zone)
    @session.fill_in('zoneNumber', with: zone)
    @session.click_button('Continue')
    raise "Zone invalid: #{zone}" \
      if @session.has_text?(Constants::Errors::ZONE_INVALID)
    raise 'Unknown error' unless @session.has_text?(Constants::Prompts::ZONE)
  end

  def provide_space(space)
    @session.fill_in('spaceNumber', with: space)
    @session.click_button('Next')
    raise "Space invalid: #{space}" \
      if @session.has_text?(Constants::Errors::INVALID_SPACE)
    raise 'Unknown error' unless @session.has_text?(Constants::Prompts::LENGTH)
  end

  def choose_max_parking_time!
    raise 'No maximum purchase option available.' \
      unless @session.has_button?('Max Purchase')

    @session.click_button('Max Purchase')
    raise 'Unable to select parking time' \
      unless @session.has_button?('Add Card')
  end

  def pay!(card:)
    raise "No card exists matching '#{card}'" \
      unless @session.has_button?(card)

    @session.click_button(card)
    raise 'Unable to verify the payment' \
      unless @session.has_text?('Please Confirm')

    @session.click_button('Yes')
    raise 'Unable to pay' unless @session.has_text?('You are parked!')
  end
end
