class Status < ApplicationRecord
  def self.from_tweet(tweet)
    puts 'id', tweet.id = tweet.id_str
    new(id: tweet.id, data: tweet.to_hash, text: tweet.text)
  end

  def self.from_id(id)
    tweet = get_status(id)
    from_tweet(tweet)
  end

  def self.from_url(url)
    from_id(id_from_url(url))
  end

  private

  def get_status(id)
    TwitterClient.status(id)
  end

  def id_from_url(url)
    url.split('/').last
  end
end
