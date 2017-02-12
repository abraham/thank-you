class RemoveDataFromThanks < ActiveRecord::Migration[5.1]
  def change
    remove_column :thanks, :data, :json
  end
end
