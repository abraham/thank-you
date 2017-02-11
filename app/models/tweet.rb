class Tweet < ApplicationRecord
  belongs_to :tweetable, polymorphic: true
  belongs_to :user

  validates :data, presence: true
  validates :text, presence: true
  validates :tweetable, presence: true
  validates :twitter_id, presence: true
  validates :user, presence: true
end
