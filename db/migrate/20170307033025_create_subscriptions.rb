# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid
      t.string :token, null: false, unique: true
      t.text :topics, array: true
      t.timestamp :active_at, null: false

      t.timestamps
    end
  end
end
