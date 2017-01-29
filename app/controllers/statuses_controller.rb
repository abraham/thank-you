class StatusesController < ApplicationController
  def new
  end

  def create
    status = Status.from_url(url)
    # status.save
    render plain: status.inspect
  end
end
