class Ditto < ApplicationRecord
  belongs_to :deed, counter_cache: true
  belongs_to :user, counter_cache: true

  validates :deed_id, uniqueness: { scope: :user_id, message: 'you has already been given' }
  validates :deed, presence: true
  validates :user, presence: true

  default_scope { order(created_at: :desc) }
end
