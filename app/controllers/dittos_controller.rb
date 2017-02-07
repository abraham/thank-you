class DittosController < ApplicationController
  before_action :require_signin
  before_action :find_deed, only: [:create, :new]
  before_action :not_already_thanked

  def create
    # TODO: make sure dittos_params[:deed_id] matches @deed.id
    @ditto = current_user.dittos.new(dittos_params)

    begin
      tweet = current_user.tweet("#{@ditto.text} #{deed_url(@deed)}", @deed.reply_to_tweet_id)
      if tweet
        @ditto.tweet_id = tweet.id
        @ditto.data = tweet.to_hash
        # TODO: error handling
        @ditto.save
      else
        flash[:warning] = 'Posting to Twitter currently disabled.'
      end
    rescue Twitter::Error::Forbidden => error
      logger.error "Error posting Ditto to Twitter Code: #{error.code} Message: #{error.message}"
      flash[:error] = "Something went wrong posting to Twitter. Code: #{error.code} - #{error.message}"
      redirect_to @deed and return
    end

    if @ditto.save
      flash[:notice] = 'Thank You was successfully created.'
      redirect_to @deed
    else
      render :new
    end
  end

  def new
    @ditto = @deed.dittos.new(text: @deed.text)
  end

  private

  def not_already_thanked
    redirect_to deed_path(@deed) if current_user.dittoed?(@deed)
  end

  def find_deed
    @deed = Deed.find(params[:deed_id])
  end

  def dittos_params
    params.require(:ditto).permit(:text, :deed_id)
  end
end
