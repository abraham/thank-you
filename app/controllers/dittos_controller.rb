class DittosController < ApplicationController
  def create
  end

  def new
    @thank = Thank.find(params[:id])
  end
end
