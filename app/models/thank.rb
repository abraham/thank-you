class Thank < ApplicationRecord
  validates :text, presence: true

  has_many :dittos
end
