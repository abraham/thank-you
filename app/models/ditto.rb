class Ditto < ApplicationRecord
  default_scope { order(created_at: :desc) }

  validates :thank_id, uniqueness: { scope: :user_id, message: 'you has already been given' }

  belongs_to :thank, counter_cache: true
  belongs_to :user, counter_cache: true
end
