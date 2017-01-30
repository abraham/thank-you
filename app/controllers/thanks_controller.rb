class ThanksController < ApplicationController
  def create
    thank = Thank.create(thanks_params)

    # render plain: thanks.inspect
    redirect_to thanks_show_path(thank)
  end

  def index
    @thanks = Thank.all
  end

  def show
    @thank = Thank.find(params[:id])
  end

  def new
  end

  private

  def thanks_params
    params.require(:thanks).permit(:text, :in_reply_to_status_id)
  end
end
