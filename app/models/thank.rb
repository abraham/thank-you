class Thank < ApplicationRecord
  include Twitter::Validation

  belongs_to :deed, counter_cache: true
  belongs_to :user, counter_cache: true

  validate :text_length, unless: :twitter_id
  validates :data, presence: true, if: :twitter_id
  validates :deed_id, uniqueness: { scope: :user_id, message: 'has already been thanked' }
  validates :deed, presence: true
  validates :text, presence: true
  validates :twitter_id, presence: true
  validates :url, presence: true, unless: :twitter_id
  validates :user, presence: true

  attr_accessor :url

  default_scope { order(created_at: :desc) }

  def tweet
    return false unless tweetable?
    status = user.tweet(full_text, deed.twitter_id)
    self.data = status.to_hash
    self.twitter_id = status.id
  end

  private

  def full_text
    "#{text} #{url}".strip
  end

  def tweetable?
    valid?
    errors.full_messages == ["Twitter can't be blank"]
  end

  def text_length
    errors.add(:twitter, 'is not a valid tweet') if tweet_invalid?(full_text)
  end
end
