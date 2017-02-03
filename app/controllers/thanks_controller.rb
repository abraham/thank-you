class ThanksController < ApplicationController
  before_action :require_signin, except: [:index, :show]
  before_action :require_admin, except: [:index, :show]

  def create
    thank = current_user.thanks.create(thanks_params)
    # TODO: catch save errors
    flash[:notice] = 'Thank you created successfully.'
    redirect_to thanks_show_path(thank)
  end

  def index
    @thanks = Thank.all.includes(dittos: :user).limit(25)
  end

  def show
    @thank = Thank.where(id: params[:id]).includes(:links, dittos: :user).first
  end

  def new
  end

  private

  def thanks_params
    params.require(:thanks).permit(:name, :reply_to_tweet_id, :text)
  end
end
