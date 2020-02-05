# frozen_string_literal: true

require 'spec_helper'

describe 'Given a parking bot' do
  before(:each) do
    @bot = ParkingBot.new
  end

  context 'When I visit the verification page' do
    before(:each) do
      allow_any_instance_of(Capybara::Session)
        .to receive(:visit)
        .with('https://ppprk.com/park/#verify')
        .and_return(File.read('spec/fixtures/verification_page.html'))
      @bot.go_to_verification_page!
    end

    example 'Then I can enter my phone number' do
      expect(@bot.session.page.find(:xpath, "//button[contains(text(), 'Text Me')]"))
        .not_to be_empty
      expect(@bot.session.page.find(:xpath, "//input[@id='regPhoneNo']"))
        .not_to be_empty
    end
  end
end
