class CreateStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :statuses, id: false do |t|
      t.string :id, null: false
      t.json :data, null: false
      t.text :text, null: false

      t.timestamps
    end
    add_index :statuses, :id
  end
end
