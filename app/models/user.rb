class User < ApplicationRecord
  has_many :thanks
  has_many :links
  has_many :deeds

  validates :access_token_secret, presence: true
  validates :access_token, presence: true
  validates :avatar_url, presence: true
  validates :data, presence: true
  validates :email, presence: true
  validates :name, presence: true
  validates :screen_name, presence: true
  validates :twitter_id, presence: true

  def thanked?(deed)
    thanks.exists?(deed_id: deed.id)
  end

  def tweet(text, in_reply_to_status_id)
    twitter_client.update(text, in_reply_to_status_id: in_reply_to_status_id) if AppConfig.posting_to_twitter_enabled
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
    AppConfig.admin_twitter_ids.include?(twitter_id)
  end

  def self.from_twitter(twitter_user, access_token)
    User.find_or_initialize_by(twitter_id: twitter_user.id).tap do |user|
      user.data = twitter_user.to_hash
      user.name = twitter_user.name
      user.screen_name = twitter_user.screen_name
      user.avatar_url = twitter_user.profile_image_uri_https
      user.email = twitter_user.email
      user.access_token = access_token.token
      user.access_token_secret = access_token.secret
      user.save
    end
  end

  private

  def etled?
    data.present?
  end
end
