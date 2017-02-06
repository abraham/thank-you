class ThanksController < ApplicationController
  before_action :require_signin, except: [:index, :show]
  before_action :require_admin, except: [:index, :show]

  def create
    thank = current_user.thanks.create(thanks_params)
    # TODO: catch save errors
    flash[:notice] = 'Thank you created successfully.'
    redirect_to thank
  end

  def index
    @thanks = Thank.includes(dittos: :user).limit(25)
  end

  def show
    @thank = Thank.includes(:links, dittos: :user).find(params[:id])
  end

  def new
  end

  private

  def thanks_params
    params.require(:thanks).permit(:name, :reply_to_tweet_id, :text)
  end
end
