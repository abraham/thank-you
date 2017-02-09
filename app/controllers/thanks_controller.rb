class ThanksController < ApplicationController
  before_action :require_signin
  before_action :find_deed, only: [:create, :new]
  before_action :not_already_thanked

  def create
    @thank = current_user.thanks.new(thanks_params.merge(deed: @deed))

    # begin
    #   tweet = current_user.tweet("#{@thank.text} #{deed_url(@deed)}", @deed.reply_to_tweet_id)
    #   if tweet
    #     @thank.tweet_id = tweet.id
    #     @thank.data = tweet.to_hash
    #   else
    #     # TODO: improve error handling
    #     flash[:warning] = 'Posting to Twitter currently disabled.'
    #   end
    # rescue Twitter::Error::Forbidden => error
    #   logger.error "Error posting Thank You to Twitter Code: #{error.code} Message: #{error.message}"
    #   flash[:error] = "Something went wrong posting to Twitter. Code: #{error.code} - #{error.message}"
    #   redirect_to @deed and return
    # end

    if @thank.save
      flash[:notice] = 'Thank You was successfully created.'
      redirect_to @deed
    else
      render :new
    end
  end

  def new
    @thank = @deed.thanks.new(text: @deed.text)
  end

  private

  def not_already_thanked
    redirect_to deed_path(@deed) if current_user.thanked?(@deed)
  end

  def find_deed
    @deed = Deed.find(params[:deed_id])
  end

  def thanks_params
    params.require(:thank).permit(:text)
  end
end
