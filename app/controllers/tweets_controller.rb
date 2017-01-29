class TweetsController < ApplicationController
  def new
  end

  def create
    id = Tweet.id_from_url params[:tweet][:url]
    tweet = Tweet.find_by id: id
    unless tweet
      tweet = Tweet.from_id id
      tweet.save
    end
    redirect_to new_thank_path(tweet)
  end
end
