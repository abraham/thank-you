# frozen_string_literal: true

class RenameReplyToTweetIdToTwitterId < ActiveRecord::Migration[5.1]
  def change
    rename_column :deeds, :reply_to_tweet_id, :twitter_id
  end
end
