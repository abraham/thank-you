class TweetsController < ApplicationController
  def new
  end

  def create
    tweet = Tweet.from_url(url)
    # tweet.save
    render plain: tweet.inspect
  end
end
