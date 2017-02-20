class Deed < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :thanks
  has_many :links

  validate :names_size
  validates :data, presence: true, if: :twitter_id
  validates :names, presence: true
  validates :text, presence: true
  validates :user, presence: true

  before_validation :clean_twitter_id
  before_validation :clean_names
  before_validation :etl!

  default_scope { order(created_at: :desc) }

  def display_text
    "Thank You #{display_names} for #{text}"
  end

  def display_names
    names.map { |n| "@#{n}" }.to_sentence
  end

  def etl!
    return if twitter_id.blank? || data.present?
    twitter_status = user.client.status(twitter_id)
    self.data = twitter_status.to_hash
  rescue Twitter::Error => error
    errors.add(:twitter_id, "error: #{error.message}")
  end

  def tweet
    @tweet ||= Twitter::Tweet.new(data.deep_symbolize_keys)
  end

  def tweet?
    twitter_id.present? && data.present?
  end

  private

  def names_size
    errors.add(:names, 'has too many values') if names && names.size > 4
  end

  def clean_twitter_id
    self.twitter_id = nil if twitter_id.blank?
  end

  def clean_names
    self.names = names.reject { |name| name.nil? || name.blank? } if names.present?
  end
end
