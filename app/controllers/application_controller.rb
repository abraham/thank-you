class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :check_for_alpha_token

  helper_method :current_user

  private

  def check_for_alpha_token
    return if Rails.env.test?
    render plain: 'Forbidden', status: :forbidden unless cookies[:alpha_token] && cookies[:alpha_token] == AppConfig.alpha_token
  end

  def current_user
    @_current_user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end

  def require_signin
    return if current_user

    redirect_to new_sessions_path, flash: { warning: 'You must be signed in to do that' }
  end

  def require_admin
    return if current_user && current_user.admin?

    redirect_to root_path, flash: { error: 'You do not have permission to do that' }
  end
end
