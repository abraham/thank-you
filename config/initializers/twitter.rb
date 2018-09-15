# frozen_string_literal: true

TwitterClient = Twitter::REST::Client.new do |config|
  config.consumer_key    = Rails.application.secrets.twitter_consumer_key
  config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
end
