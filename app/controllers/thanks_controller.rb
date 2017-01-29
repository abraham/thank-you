class ThanksController < ApplicationController
  def create
    thanks = Thanks.create(thanks_params)

    redirect_to thanks
  end

  def index; end

  def show
    @thanks = Thanks.find(params[:id])
  end

  def new; end

  private

  def thanks_params
    params.require(:thanks).permit(:status_id, :text)
  end
end
