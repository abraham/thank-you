class LinksController < ApplicationController
  before_action :require_signin
  before_action :find_thank, only: [:create, :new]

  def create
    link = Link.new(links_params)
    link.thank = @thank
    link.user = current_user

    if link.save
      flash[:notice] = 'Link was successfully created.'
      redirect_to thank_path(@thank)
    else
      render 'new'
    end
  end

  def new
  end

  private

  def links_params
    params.require(:link).permit(:text, :url)
  end

  def find_thank
    @thank = Thank.find(params[:thank_id])
  end
end
