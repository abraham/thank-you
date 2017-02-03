class Thank < ApplicationRecord
  default_scope { order(created_at: :desc) }

  validates :text, presence: true

  belongs_to :user
  has_many :dittos
  has_many :links

  def update_dittos_count
    update(dittos_count: dittos.count)
  end
end
