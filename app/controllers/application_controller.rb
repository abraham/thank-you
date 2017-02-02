class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: cookies[:user_id])
  end

  def require_signin
    return if current_user

    redirect_to sessions_new_path
  end
end
