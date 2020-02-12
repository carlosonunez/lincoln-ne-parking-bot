# frozen_string_literal: true

describe 'Given an app that pays for parking from the command line' do
  context 'When I run it locally' do
    example 'Then it pays for my parking', :integration_local do
      expect { system('ruby bin/parking_bot.rb') }.not_to raise_error
    end
  end
end
