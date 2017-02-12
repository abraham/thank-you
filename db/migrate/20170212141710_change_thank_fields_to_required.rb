class ChangeThankFieldsToRequired < ActiveRecord::Migration[5.1]
  def change
    change_column_null :thanks, :data, false
    remove_column :thanks, :tweet_id, :uuid
    add_column :thanks, :twitter_id, :string, null: false
    add_index :thanks, :twitter_id, unique: true
  end
end
