class TweetsController < ApplicationController
  def new
  end

  def create
    id = Tweet.id_from_url params[:tweet][:url]
    tweet = Tweet.find_by id: id
    if tweet
      render plain: 'found tweet'
    else
      tweet = Tweet.from_id id
      tweet.save
      render plain: tweet.inspect
    end
  end
end
