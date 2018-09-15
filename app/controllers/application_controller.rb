# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :set_raven_context
  before_action :require_active_user

  helper_method :current_user
  helper_method :current_subscription

  private

  def set_raven_context
    Raven.user_context(id: session[:user_id])
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def current_user
    @current_user ||= session[:user_id] && User.find(session[:user_id])
  end

  def current_subscription
    @current_subscription ||= session[:subscription_id] && Subscription.find(session[:subscription_id])
  end

  def require_active_user
    return unless current_user&.disabled?

    reset_session
    redirect_to root_url, flash: { warning: 'Your account is not activated.' }
  end

  def require_signin
    return if current_user

    session[:next_path] = request.path if request.get?

    redirect_to new_sessions_path, flash: { warning: 'You must be signed in to do that.' }
  end

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, flash: { warning: 'You do not have permission to do that.' }
  end

  def require_editor
    return if current_user && (current_user.editor? || current_user.moderator? || current_user.admin?)

    redirect_to root_path, flash: { warning: 'You do not have permission to do that.' }
  end

  def render_not_found
    render :not_found, status: :not_found
  end

  def render_forbidden
    render :not_found, status: :forbidden
  end

  def render_forbidden_json
    render json: {}, status: :forbidden
  end
end
