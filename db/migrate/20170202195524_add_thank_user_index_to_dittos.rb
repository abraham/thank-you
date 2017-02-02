class AddThankUserIndexToDittos < ActiveRecord::Migration[5.1]
  def change
    add_index :dittos, [:thank_id, :user_id], unique: true
  end
end
