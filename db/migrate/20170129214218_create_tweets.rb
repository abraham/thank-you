class CreateTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets, id: false do |t|
      t.string :id, null: false
      t.json :data, null: false
      t.text :text, null: false

      t.timestamps
    end
    add_index :tweets, :id
  end
end
