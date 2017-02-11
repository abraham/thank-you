class Deed < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :thanks
  has_many :links

  validate :name_size
  validates :name, presence: true
  validates :text, presence: true
  validates :user, presence: true

  default_scope { order(created_at: :desc) }

  def display_text
    "Thank You #{display_names} for #{text}"
  end

  def display_names
    name.map { |n| "@#{n}" }.to_sentence
  end

  private

  def name_size
    errors.add(:name, 'has too many values') if name && name.size > 3
  end
end
