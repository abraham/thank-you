class Ditto < ApplicationRecord
  default_scope { order(created_at: :desc) }

  validates :thank_id, uniqueness: { scope: :user_id, message: 'you has already been given' }

  belongs_to :thank
  belongs_to :user

  after_save -> { thank.update_dittos_count }
end
