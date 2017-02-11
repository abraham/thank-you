class CreateTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets, id: :uuid do |t|
      t.string :twitter_id, null: false, index: { unique: true }
      t.string :text, null: false
      t.references :user, null: false, type: :uuid
      t.json :data, null: false
      t.references :tweetable, polymorphic: true, type: :uuid, index: { unique: true }

      t.timestamps
    end

    remove_column :thanks, :tweet_id, :uuid
  end
end
