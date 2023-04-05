# frozen_string_literal: true

require 'twilio-ruby'

# account_sid = ENV['TWILIO_ACCOUNT_SID']
# auth_token = ENV['TWILIO_AUTH_TOKEN']
account_sid = 'YOUR_TWILIO_ACCOUNT_SID'
auth_token = 'YOUR_TWILIO_AUTH_TOKEN'

Twilio.configure do |config|
  config.account_sid = account_sid
  config.auth_token = auth_token
end

TWILIO_CLIENT = Twilio::REST::Client.new
