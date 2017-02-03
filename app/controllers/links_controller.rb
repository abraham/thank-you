class LinksController < ApplicationController
  before_action :require_signin

  def create
    thank = Thank.find(params[:thank_id])
    link = Link.new(links_params)
    link.thank = thank
    link.user = current_user

    if link.save
      flash[:notice] = 'Citation was successfully created.'
      redirect_to thank_path(thank)
    else
      render 'new'
    end
  end

  def new
    @thank = Thank.find(params[:thank_id])
  end

  private

  def links_params
    params.require(:link).permit(:text, :url)
  end
end
