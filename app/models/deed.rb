class Deed < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :thanks
  has_many :links

  validates :text, presence: true
  validates :user, presence: true

  default_scope { order(created_at: :desc) }
end
