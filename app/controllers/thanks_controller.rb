class ThanksController < ApplicationController
  def create
    thank = current_user.thanks.create(thanks_params)

    redirect_to thanks_show_path(thank)
  end

  def index
    @thanks = Thank.all.limit(25)
  end

  def show
    @thank = Thank.find(params[:id])
  end

  def new
  end

  private

  def thanks_params
    params.require(:thanks).permit(:name, :reply_to_tweet_id, :text)
  end
end
