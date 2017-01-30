class RemoveStatusIdFromThanks < ActiveRecord::Migration[5.1]
  def change
    remove_column :thanks, :status_id
  end
end
