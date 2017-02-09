class Link < ApplicationRecord
  belongs_to :deed
  belongs_to :user

  validates :deed, presence: true
  validates :user, presence: true
  validates :text, presence: true
  validates :url, presence: true
end
