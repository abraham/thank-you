class ThanksController < ApplicationController
  def create
    thanks = Thanks.create(thanks_params)

    redirect_to thanks
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
    params.require(:thanks).permit(:status_id, :text)
  end
end
