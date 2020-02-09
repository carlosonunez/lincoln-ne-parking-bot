# frozen_string_literal: true

require 'parking_bot/session'
require 'parking_bot/constants'

class ParkingBot
  attr_accessor :session

  def initialize
    @session = ParkingBot::Session.create
  end

  # First, we need to enter our phone number.
  def go_to_verification_page!
    @session.visit(Constants::URL::VERIFICATION)
  end

  # Then we need to enter a code
  def provide_phone_number(phone_number)
    @session.fill_in('regPhoneNo', with: phone_number)
    @session.click_button('Text Me')
    @session.click_button('Yes')
  rescue StandardError
    raise 'Failed to provide phone number'
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
