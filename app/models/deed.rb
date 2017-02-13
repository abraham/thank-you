class Deed < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :thanks
  has_many :links

  validate :names_size
  validates :data, presence: true, if: :twitter_id
  validates :names, presence: true
  validates :text, presence: true
  validates :user, presence: true

  default_scope { order(created_at: :desc) }

  def display_text
    "Thank You #{display_names} for #{text}"
  end

  def display_names
    names.map { |n| "@#{n}" }.to_sentence
  end

  private

  def names_size
    errors.add(:names, 'has too many values') if names && names.size > 3
  end
end
