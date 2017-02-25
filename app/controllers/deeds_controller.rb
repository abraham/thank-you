class DeedsController < ApplicationController
  before_action :require_signin, except: [:index, :show]
  before_action :require_admin, except: [:index, :show]

  def create
    @deed = current_user.deeds.create(deeds_params)

    if @deed.valid?
      redirect_to @deed, flash: { notice: 'Deed created successfully.' }
    else
      render :new
    end
  end

  def index
    @deeds = Deed.published.includes(thanks: :user).limit(25)
    @thanked_deed_ids = Thank.where(deed: @deeds).where(user: current_user).pluck(:deed_id)
  end

  def show
    @deed = Deed.includes(:links, thanks: :user).find(params[:id])
    render_not_found unless @deed.published? || user_can_view?
    @thanked = current_user && current_user.thanked?(@deed)
  end

  def new
    @deed = Deed.new
  end

  private

  def user_can_view?
    current_user && (current_user.admin? || current_user == @deed.user)
  end

  def deeds_params
    params.require(:deed).permit(:twitter_id, :text, names: [])
  end
end
