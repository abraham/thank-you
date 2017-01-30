class ThanksController < ApplicationController
  def create
    thanks = Thanks.new(thanks_params)
    thanks.tweet = Tweet.find params[:tweet_id]

    render plain: thanks.inspect
    # redirect_to thanks
  end

  def index
    @thanks = Thanks.all
  end

  def show
    @thank = Thanks.find(params[:id])
  end

  def new
    @tweet = Tweet.find(params[:tweet_id])
  end

  private

  def thanks_params
    params.require(:thanks).permit(:text)
  end
end
