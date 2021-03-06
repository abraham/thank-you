# frozen_string_literal: true

class ThanksController < ApplicationController
  before_action :require_signin
  before_action :find_deed, only: [:create, :new]
  before_action :deed_published
  before_action :not_already_thanked

  def create
    @thank = current_user.thanks.new(deed: @deed, text: params[:thank][:text], url: deed_url(@deed))

    if @thank.tweet && @thank.save
      redirect_to @deed, flash: { notice: 'Thank You has been tweeted.' }
    else
      render :new
    end
  rescue Twitter::Error => e
    @thank.errors.add(:twitter_id, "error: #{e.message}")
    render :new
  end

  def new
    @thank = @deed.thanks.new(text: @deed.thank_text)
  end

  private

  def deed_published
    return if @deed.published?

    flash[:error] = 'Deed must be published first.'
    redirect_to deed_path(@deed)
  end

  def not_already_thanked
    return unless current_user.thanked?(@deed)

    flash[:error] = 'Already thanked'
    redirect_to deed_path(@deed)
  end

  def find_deed
    @deed = Deed.find(params[:deed_id])
  end

  def thanks_params
    params.require(:thank).permit(:text)
  end
end
