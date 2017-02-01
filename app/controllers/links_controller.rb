class LinksController < ApplicationController
  def create
    thank = Thank.find(params[:id])
    link = Link.new(links_params)
    link.thank = thank
    link.user = current_user
    link.save
    # TODO: check for success and add flash

    redirect_to thanks_show_path(thank)
  end

  def new
    @thank = Thank.find(params[:id])
  end

  private

  def links_params
    params.require(:link).permit(:text, :url)
  end
end
