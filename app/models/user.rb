class User < ApplicationRecord
  enum status: { active: 0, disabled: 1, expired: 2 }

  has_many :deeds
  has_many :links
  has_many :thanks

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
    raise 'Posting to Twitter disabled' unless AppConfig.posting_to_twitter_enabled
    client.update(text, in_reply_to_status_id: in_reply_to_status_id)
  end

  def admin?
    AppConfig.admin_twitter_ids.include?(twitter_id)
  end

  def self.from_access_token(user_id, access_token, access_token_secret)
    User.find_or_initialize_by(twitter_id: user_id).tap do |user|
      user.access_token = access_token
      user.access_token_secret = access_token_secret
      user.etl!
      user.save
    end
  end

  def etled?
    data.present?
  end

  def etl!
    twitter_user = client.user(include_email: true)
    self.data = twitter_user.to_hash
    self.name = twitter_user.name
    self.screen_name = twitter_user.screen_name
    self.avatar_url = twitter_user.profile_image_uri_https
    self.email = twitter_user.email
    self.default_avatar = twitter_user.default_profile_image?
  end

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      config.access_token = access_token
      config.access_token_secret = access_token_secret
    end
  end
end
