class ThanksController < ApplicationController
  before_action :require_signin
  before_action :find_deed, only: [:create, :new]
  before_action :not_already_thanked

  def create
    text = params[:thank][:text]
    text = "#{params[:thank][:text]} #{deed_url(@deed)}" unless text && text.include?(deed_url(@deed))
    @thank = current_user.thanks.new(deed: @deed, text: text)

    @thank.tweet if params[:thank][:text]

    if @thank.save
      flash[:notice] = 'Thank You was successfully created.'
      redirect_to @deed
    else
      render :new
    end
  end

  def new
    @thank = @deed.thanks.new(text: @deed.display_text)
  end

  private

  def not_already_thanked
    return unless current_user.thanked?(@deed)
    flash[:error] = "You already thanked #{@deed.display_names}"
    redirect_to deed_path(@deed)
  end

  def find_deed
    @deed = Deed.find(params[:deed_id])
  end

  def thanks_params
    params.require(:thank).permit(:text)
  end
end
