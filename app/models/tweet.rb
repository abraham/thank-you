class Tweet < ApplicationRecord
  self.primary_key = :id

  def self.from_id(id)
    tweet = get_tweet id

    new(id: tweet.id, data: tweet.to_hash, text: tweet.text)
  end

  def self.id_from_url(url)
    url.split('/').last
  end

  private

  def self.get_tweet(id)
    TwitterClient.status(id)
  end
end
