class AddDataToDeed < ActiveRecord::Migration[5.1]
  def change
    add_column :deeds, :data, :json
  end
end
