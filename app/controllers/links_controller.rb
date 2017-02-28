class LinksController < ApplicationController
  before_action :require_signin
  before_action :find_deed
  before_action :require_edit_access

  def create
    @link = current_user.links.build(links_params)
    @link.deed = @deed

    if @link.save
      redirect_to @deed, flash: { notice: 'Link was successfully created.' }
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

  def user_can_modify_deed?
    current_user && current_user.edit?(@deed)
  end

  def require_edit_access
    return if user_can_modify_deed?

    redirect_to deed_path(@deed), flash: { warning: 'You do not have permission to do that' }
  end
end
