class AddStatusToDeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :deeds, :status, :integer, default: 0, null: false
  end
end
