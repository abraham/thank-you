class Tweet < ApplicationRecord
  self.primary_key = :id
  has_many :thanks

  validates :id, presence: true

  def self.from_id(id)
    tweet = get_tweet id

    new(id: tweet.id,
        data: tweet.to_hash,
        text: tweet.text)
  end

  def self.id_from_url(url)
    url.split('/').last
  end

  def self.get_tweet(id)
    TwitterClient.status(id)
  end
end
