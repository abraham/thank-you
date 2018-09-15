# frozen_string_literal: true

class RenameDittosStatusIdToTweetId < ActiveRecord::Migration[5.1]
  def change
    rename_column :dittos, :status_id, :tweet_id
  end
end
