class AddDittosCountToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :dittos_count, :integer, null: false, default: 0
  end
end
