class AddTweetRefToThanks < ActiveRecord::Migration[5.1]
  def change
    add_reference :thanks, :tweet, foreign_key: true, type: :string, null: false
  end
end
