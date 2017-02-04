class Link < ApplicationRecord
  belongs_to :thank
  belongs_to :user

  validates :thank, presence: true
  validates :user, presence: true
end
