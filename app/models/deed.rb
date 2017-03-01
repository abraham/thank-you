class Deed < ApplicationRecord
  enum status: { draft: 0, published: 1, archived: 2, disabled: 3 }

  belongs_to :user, counter_cache: true
  has_many :thanks
  has_many :links

  validate :names_size
  validates :data, presence: true, if: :twitter_id
  validates :names, presence: true
  validates :text, presence: true
  validates :user, presence: true

  before_validation :clean_twitter_data
  before_validation :clean_names
  before_validation :etl

  default_scope { order(created_at: :desc) }

  def thank_text
    "Thank You #{display_names} for #{text}"
  end

  def display_text
    "#{display_names} #{names.size == 1 ? 'is' : 'are'} #{text}"
  end

  def display_names
    names.map { |n| "@#{n}" }.to_sentence
  end

  def etl
    return unless etl?
    twitter_status = user.client.status(twitter_id)
    self.data = twitter_status.to_hash
    self.twitter_id = twitter_status.id
  rescue Twitter::Error => error
    errors.add(:twitter_id, "error: #{error.message}")
  end

  def tweet
    @tweet ||= Twitter::Tweet.new(data.deep_symbolize_keys) if tweet?
  end

  def tweet?
    twitter_id.present? && data.present?
  end

  private

  def etl?
    twitter_id.present? && (data.blank? || twitter_id != data['id'].to_s)
  end

  def names_size
    errors.add(:names, 'has too many values') if names && names.size > 4
  end

  def clean_twitter_data
    self.twitter_id = nil if twitter_id.blank?
    self.data = nil if twitter_id.blank?
  end

  def clean_names
    return unless names.present?
    self.names = names.reject { |name| name.nil? || name.blank? }
    self.names = names.map { |name| name.gsub(/[^a-z0-9_]/i, '') }
  end
end
