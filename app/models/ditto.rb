class Ditto < ApplicationRecord
  default_scope { order(created_at: :desc) }

  belongs_to :thank
  belongs_to :user
end
