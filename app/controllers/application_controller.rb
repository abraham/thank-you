class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    User.find(cookies[:user_id])
  end
end
