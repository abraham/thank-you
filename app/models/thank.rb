class Thank < ApplicationRecord
  default_scope { order(created_at: :desc) }

  validates :text, presence: true

  has_many :dittos
  belongs_to :users
end
