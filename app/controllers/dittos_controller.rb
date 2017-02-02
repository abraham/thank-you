class DittosController < ApplicationController
  before_action :require_signin

  def create
    thank = Thank.find(params[:id])
    ditto = Ditto.new(dittos_params)
    ditto.thank = thank
    ditto.user = current_user
    tweet = current_user.tweet(ditto.text, thank.reply_to_tweet_id)
    ditto.tweet_id = tweet.id
    ditto.data = tweet.to_hash

    if ditto.save
      flash[:notice] = 'Thank you was successfully created.'
      redirect_to thanks_show_path(thank)
    else
      render 'new'
    end
  end

  def new
    @thank = Thank.find(params[:id])
  end

  private

  def dittos_params
    params.require(:ditto).permit(:text)
  end
end
