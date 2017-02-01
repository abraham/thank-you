class RenameThanksInReplyToStatusIdToReplyTweetId < ActiveRecord::Migration[5.1]
  def change
    rename_column :thanks, :in_reply_to_status_id, :reply_to_tweet_id
  end
end
