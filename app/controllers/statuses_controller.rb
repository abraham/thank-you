class StatusesController < ApplicationController
  def new
  end

  def create
    render plain: status_params.inspect
  end

  private

  def status_params
    params.require(:status).permit(:url)
  end
end
