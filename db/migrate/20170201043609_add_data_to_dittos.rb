class AddDataToDittos < ActiveRecord::Migration[5.1]
  def change
    add_column :dittos, :data, :json, null: false
  end
end
