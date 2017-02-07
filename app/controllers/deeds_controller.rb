class DeedsController < ApplicationController
  before_action :require_signin, except: [:index, :show]
  before_action :require_admin, except: [:index, :show]

  def create
    deed = current_user.deeds.create(deeds_params)
    # TODO: catch save errors
    flash[:notice] = 'Deed you created successfully.'
    redirect_to deed
  end

  def index
    @deeds = Deed.includes(dittos: :user).limit(25)
  end

  def show
    @deed = Deed.includes(:links, dittos: :user).find(params[:id])
  end

  def new
  end

  private

  def deeds_params
    params.require(:deeds).permit(:name, :reply_to_tweet_id, :text)
  end
end
