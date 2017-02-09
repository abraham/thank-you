class Link < ApplicationRecord
  belongs_to :deed
  belongs_to :user

  validates :deed, presence: true
  validates :user, presence: true
  validates :text, presence: true
  validates :url, presence: true
  validate :url_protocol

  private

  def url_protocol
    return if url.starts_with?('http://') || url.starts_with?('https://')
    errors.add(:url, 'must be a valid URL')
  end
end
