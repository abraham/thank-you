class Tweet < ApplicationRecord
  belongs_to :tweetable, polymorphic: true
  belongs_to :user

  validates :text, presence: true
  validates :data, presence: true
  validates :user, presence: true
  validates :tweetable, presence: true
end
