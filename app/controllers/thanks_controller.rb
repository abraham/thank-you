class ThanksController < ApplicationController
  def create
    thank = Thank.create(thanks_params)

    redirect_to thanks_show_path(thank)
  end

  def ditto
    @thank = Thank.find(params[:id])
  end

  def index
    @thanks = Thank.all.limit(25)
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
