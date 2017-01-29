class CreateTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets, id: false do |t|
      t.string :id, null: false, unique: true
      t.json :data, null: false
      t.text :text, null: false

      t.timestamps
    end
    add_index :tweets, :id, unique: true
  end
end
