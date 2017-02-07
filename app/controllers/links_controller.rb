class LinksController < ApplicationController
  before_action :require_signin
  # TODO: enable this
  # before_action :require_admin
  before_action :find_deed, only: [:create, :new]

  def create
    # TODO: validate admin
    link = current_user.links.new(links_params)

    if link.save
      flash[:notice] = 'Link was successfully created.'
      redirect_to @deed
    else
      render :new
    end
  end

  def new
    @link = @deed.links.new
  end

  private

  def links_params
    params.require(:link).permit(:text, :url, :deed_id)
  end

  def find_deed
    @deed = Deed.find(params[:deed_id])
  end
end
