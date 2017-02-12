class Thank < ApplicationRecord
  include Twitter::Validation

  belongs_to :deed, counter_cache: true
  belongs_to :user, counter_cache: true

  validate :text_length
  validates :deed_id, uniqueness: { scope: :user_id, message: 'you has already been given' }
  validates :deed, presence: true
  validates :text, presence: true
  validates :user, presence: true

  default_scope { order(created_at: :desc) }

  private

  def text_length
    errors.add(:text, 'is not a valid tweet') if tweet_invalid?(text)
  end
end
