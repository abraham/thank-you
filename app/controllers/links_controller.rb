class LinksController < ApplicationController
  before_action :require_signin
  before_action :require_admin
  before_action :find_deed, only: [:create, :new]

  def create
    @link = current_user.links.new(links_params.merge(deed: @deed))

    if @link.save
      redirect_to @deed, flash: { notice: 'Link was successfully created.' }
    else
      flash.now[:error] = @link.errors.full_messages.to_sentence
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
