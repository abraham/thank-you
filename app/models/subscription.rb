class Subscription < ApplicationRecord
  belongs_to :user, optional: true

  validates :token, presence: true
  validates :active_at, presence: true
end
