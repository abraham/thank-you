class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_raven_context

  before_action :check_for_alpha_token
  before_action :require_active_user

  helper_method :current_user

  private

  def set_raven_context
    Raven.user_context(id: session[:user_id])
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def check_for_alpha_token
    return if Rails.env.test? || Rails.env.development?
    render plain: 'Forbidden', status: :forbidden unless cookies[:alpha_token] && cookies[:alpha_token] == AppConfig.alpha_token
  end

  def current_user
    @_current_user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end

  def require_active_user
    return unless current_user && current_user.disabled?
    reset_session
    redirect_to root_url, flash: { warning: 'Your account is not activated' }
  end

  def require_signin
    return if current_user
    session[:next_path] = request.path if request.get?

    redirect_to new_sessions_path, flash: { warning: 'You must be signed in to do that' }
  end

  def require_admin
    return if current_user && current_user.admin?

    redirect_to root_path, flash: { warning: 'You do not have permission to do that' }
  end
end
