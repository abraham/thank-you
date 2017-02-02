class AlphaController < ApplicationController
  skip_before_action :check_for_alpha_token

  def join
    cookies[:alpha_token] = params[:token] if params[:token] == AppConfig.alpha_token
    redirect_to root_path
  end
end
