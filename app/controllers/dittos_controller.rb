class DittosController < ApplicationController
  before_action :require_signin
  before_action :find_thank, only: [:create, :new]
  before_action :not_already_thanked

  def create
    @ditto = Ditto.create(dittos_params.merge(user: current_user, thank: @thank))

    begin
      tweet = current_user.tweet(@ditto.text, @thank.reply_to_tweet_id)
      if tweet
        @ditto.tweet_id = tweet.id
        @ditto.data = tweet.to_hash
        @ditto.save
      else
        flash[:warning] = 'Posting to Twitter currently disabled.'
      end
    rescue Twitter::Error::Forbidden => error
      logger.error "Error posting Ditto to Twitter Code: #{error.code} Message: #{error.message}"
      flash[:error] = "Something went wrong posting to Twitter. Code: #{error.code} - #{error.message}"
      redirect_to @thank and return
    end

    if @ditto.save
      flash[:notice] = 'Thank you was successfully created.'
      redirect_to @thank
    else
      render 'new'
    end
  end

  def new
    @ditto = Ditto.new
  end

  private

  def not_already_thanked
    redirect_to thank_path(@thank) if current_user.dittoed?(@thank)
  end

  def find_thank
    @thank = Thank.find(params[:thank_id])
  end

  def dittos_params
    params.require(:ditto).permit(:text)
  end
end
