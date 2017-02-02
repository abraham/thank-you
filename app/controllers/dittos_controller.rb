class DittosController < ApplicationController
  before_action :require_signin
  before_action :find_thank
  before_action :not_already_thanked

  def create
    @ditto = Ditto.new(dittos_params)
    @ditto.thank = @thank
    @ditto.user = current_user

    # TODO: Validate Ditto before tweeting
    begin
      tweet = current_user.tweet(@ditto.text, @thank.reply_to_tweet_id)
    rescue Twitter::Error::Forbidden => error
      logger.error "Error posting Ditto to Twitter Code: #{error.code} Message: #{error.message}"
      flash[:error] = "Something went wrong posting to Twitter. Code: #{error.code} - #{error.message}"
      redirect_to thanks_show_path(@thank) and return
    end
    @ditto.tweet_id = tweet.id
    @ditto.data = tweet.to_hash

    if @ditto.save
      flash[:notice] = 'Thank you was successfully created.'
      redirect_to thanks_show_path(@thank)
    else
      render 'new'
    end
  end

  def new
    @ditto = Ditto.new
  end

  private

  def not_already_thanked
    redirect_to thanks_show_path(@thank) if current_user.thanked?(@thank.id)
  end

  def find_thank
    @thank = Thank.find(params[:id])
  end

  def dittos_params
    params.require(:ditto).permit(:text)
  end
end
