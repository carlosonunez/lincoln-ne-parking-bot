# frozen_string_literal: true

class ParkingBot
  # This should really be a config file, though changes to these
  # URLs will probably signify larger code changes.
  # TODO: Make this happen, maybe.
  module Constants
    module Errors
      ZONE_INVALID = "This is not a zone within our system. Please try a \
different zone before continuing."
      INVALID_PIN = 'Either the phone number/email or PIN you entered \
is incorrect. Please try again'
    end
    ZONE_PROMPT = 'Enter the space number in zone'
    VERIFICATION_LINK = 'https://ppprk.com/park/#verify'
  end
end
