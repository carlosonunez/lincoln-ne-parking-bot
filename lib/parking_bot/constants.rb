# frozen_string_literal: true

class ParkingBot
  # This should really be a config file, though changes to these
  # URLs will probably signify larger code changes.
  # TODO: Make this happen, maybe.
  module Constants
    module URL
      VERIFICATION = 'https://ppprk.com/park/#verify'
    end
    module Prompts
      ZONE = 'Enter the space number in zone'
      LENGTH = 'Please select the length of stay'
    end
    module Errors
      ZONE_INVALID = "This is not a zone within our system. Please try a \
different zone before continuing."
      INVALID_PIN = 'Either the phone number/email or PIN you entered \
is incorrect. Please try again'
      INVALID_SPACE = 'The space you entered is invalid. \
Please verify or try another space.'
    end
  end
end
