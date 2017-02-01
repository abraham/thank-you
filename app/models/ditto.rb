class Ditto < ApplicationRecord
  belongs_to :thank
  belongs_to :user

  # TODO: save tweet data
end
