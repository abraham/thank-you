class ThanksController < ApplicationController
  def create
    thanks = Thanks.new(thanks_params)

    render plain: thanks.inspect
    # redirect_to thanks
  end

  def index
    @thanks = Thanks.all
  end

  def show
    @thank = Thanks.find(params[:id])
  end

  def new
  end

  private

  def thanks_params
    params.require(:thanks).permit(:text, :in_reply_to_status_id)
  end
end
