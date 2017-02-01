class DittosController < ApplicationController
  def create
    thank = Thank.find(params[:id])
    ditto = Ditto.new(dittos_params)
    ditto.thank = thank
    tweet = current_user.tweet(ditto.text, nil)
    ditto.tweet_id = tweet.id
    ditto.data = tweet.to_hash
    ditto.save

    redirect_to thank
  end

  def new
    @thank = Thank.find(params[:id])
  end

  private

  def dittos_params
    params.require(:ditto).permit(:text)
  end
end
