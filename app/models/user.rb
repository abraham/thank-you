class User < ApplicationRecord
  # TODO :status[active, disabled]

  def tweet(text, in_rpely_to_status_id)
    twitter_client.update(text, in_rpely_to_status_id: in_rpely_to_status_id)
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      config.access_token = access_token
      config.access_token_secret = access_token_secret
    end
  end
end
