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
    @session.visit(Constants::VERIFICATION_LINK)
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
    failure_message = 'Either the phone number/email or PIN you entered \
is incorrect. Please try again'
    @session.fill_in('pin', with: pin)
    @session.click_button('Sign In')
    raise 'PIN not valid' if @session.has_text?(failure_message)
  rescue StandardError
    raise 'Something went wrong'
  end
end
