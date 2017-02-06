class LinksController < ApplicationController
  before_action :require_signin
  before_action :require_admin
  before_action :find_thank, only: [:create, :new]

  def create
    # TODO: validate admin
    link = current_user.links.new(links_params)

    if link.save
      flash[:notice] = 'Link was successfully created.'
      redirect_to @thank
    else
      render :new
    end
  end

  def new
    @link = @thank.links.new
  end

  private

  def links_params
    params.require(:link).permit(:text, :url, :thank_id)
  end

  def find_thank
    @thank = Thank.find(params[:thank_id])
  end
end
