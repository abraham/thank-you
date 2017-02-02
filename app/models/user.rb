class User < ApplicationRecord
  # TODO :status[active, disabled]
  has_many :dittos
  has_many :links
  has_many :thanks

  def thanked?(thank_id)
    dittos.where(thank_id: thank_id).count > 0
  end

  def tweet(text, in_reply_to_status_id)
    twitter_client.update(text, in_reply_to_status_id: in_reply_to_status_id)
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      config.access_token = access_token
      config.access_token_secret = access_token_secret
    end
  end

  def admin?
    AppConfig.admin_ids.include?(twitter_id)
  end
end
