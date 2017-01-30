class AddNameToThanks < ActiveRecord::Migration[5.1]
  def change
    add_column :thanks, :name, :string, null: false
  end
end
