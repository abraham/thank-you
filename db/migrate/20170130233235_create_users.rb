# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :twitter_id, null: false, unique: true
      t.string :screen_name, null: false
      t.string :name, null: false
      t.string :avatar_url, null: false
      t.json :data, null: false
      t.string :access_token, null: false
      t.string :access_token_secret, null: false

      t.timestamps
    end
  end
end
