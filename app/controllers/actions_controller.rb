class ActionsController < ApplicationController
  def create
    render plain: params.inspect
  end

  def index
  end

  def new
  end
end
