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
end
