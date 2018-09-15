# frozen_string_literal: true

class ChangeTweetNullOnDittos < ActiveRecord::Migration[5.1]
  def change
    change_column :dittos, :tweet_id, :string, null: true
    change_column :dittos, :data, :json, null: true
  end
end
