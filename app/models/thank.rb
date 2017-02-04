class Thank < ApplicationRecord
  default_scope { order(created_at: :desc) }

  validates :text, presence: true

  belongs_to :user, counter_cache: true
  has_many :dittos
  has_many :links
end
