class AddUserToThanks < ActiveRecord::Migration[5.1]
  def change
    add_reference :thanks, :user, foreign_key: true, type: :uuid, null: false
  end
end
