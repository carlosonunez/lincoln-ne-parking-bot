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

  def wait_for!(&block)
    iterations = 0
    until iterations == (ENV['TIMEOUT_SECONDS'] || 15)
      return if block.call == true

      sleep 1
      iterations += 1
    end
    raise 'Timed out waiting on an element to appear.'
  end

  def start_login!
    @session.visit(Constants::URL::LOGIN)
    @session.find('a', text: 'Get Started').click
    @session.find('a', text: 'Accept').click if @session.has_text? 'Accept'
  end

  def provide_phone_number(phone_number)
    wait_for! { @session.has_field? 'regPhoneNo' }
    @session.fill_in('regPhoneNo', with: phone_number)
    wait_for! { @session.has_button? 'Text Me' }
    @session.click_button('Text Me')
    wait_for! { @session.has_button? 'Yes' }
    @session.click_button('Yes')
    wait_for! { @session.has_field? 'verificationCode' }
  end

  def fetch_latest_code
    queue_message = @queue.pop!
    raise 'Timed out while waiting for a code.' if queue_message.nil?

    message_body = JSON.parse(queue_message)['Message']
    encoded_email = JSON.parse(message_body)['content']
    raise 'No email found' if encoded_email.nil?

    find_code_in_email(encoded_email)
  end

  def submit_verification_code(code)
    begin
      @session.fill_in('verificationCode', with: code)
      wait_for! { @session.has_button? 'Verify' }
      @session.click_button('Verify')
    rescue StandardError
      raise 'Failed to provide verification code or verification code incorrect.'
    end
    wait_for! { @session.has_button? 'Ok' }
    @session.click_button('Ok')
  end

  def provide_pin(pin)
    wait_for! { @session.has_field? 'pin' }
    @session.fill_in('pin', with: pin)
    @session.click_button('Sign In')
    raise 'PIN not valid' if @session.has_text?(Constants::Errors::INVALID_PIN)
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
    wait_for! { @session.has_field? 'zoneNumber' }
    @session.fill_in('zoneNumber', with: zone)
    @session.click_button('Continue')
    raise "Zone invalid: #{zone}" \
      if @session.has_text?(Constants::Errors::ZONE_INVALID)
    raise 'Unknown error' unless @session.has_text?(Constants::Prompts::ZONE)
  end

  def provide_space(space)
    wait_for! { @session.has_field? 'spaceNumber' }
    @session.fill_in('spaceNumber', with: space)
    @session.click_button('Next')
    raise "Space invalid: #{space}" \
      if @session.has_text?(Constants::Errors::INVALID_SPACE)
    raise 'Unknown error' unless @session.has_text?(Constants::Prompts::LENGTH)
  end

  def choose_max_parking_time!
    begin
      wait_for! { @session.has_button? 'Max Purchase' }
    rescue StandardError
      raise "It doesn't seem that we can select 'Max Purchase'"
    end
    @session.click_button('Max Purchase')
    wait_for! { @session.has_button?('Add Card') }
  end

  def pay!(card:)
    begin
      wait_for! { session.has_button?(card) }
    rescue StandardError
      raise 'The card provided was not found. Did you set it up manually?'
    end
    @session.click_button(card)
    wait_for! { session.has_button? 'Yes' }
    @session.click_button('Yes')
    wait_for! { session.has_text? 'You are parked!' }
  end
end
