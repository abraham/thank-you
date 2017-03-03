class SessionsController < ApplicationController
  before_action :require_anonymous, except: :destroy
  before_action :require_not_denied, only: :finish
  before_action :require_request_token, only: :finish
  before_action :require_known_request_token, only: :finish

  def new
  end

  def create
    request_token = consumer.get_request_token(oauth_callback: finish_sessions_url)
    next_path = session[:next_path]
    reset_session
    session[:next_path] = next_path
    session[:request_token] = { token: request_token.token, secret: request_token.secret }
    redirect_to request_token.authorize_url
  end

  def finish
    access_token = exchange_request_token(session[:request_token], params[:oauth_verifier])
    user = User.from_access_token(access_token.params['user_id'], access_token.token, access_token.secret)
    path = next_path
    reset_session
    session[:user_id] = user.id

    redirect_to path, flash: { notice: "Signed in as @#{user.screen_name}." }
  end

  def destroy
    reset_session
    redirect_to root_path, flash: { notice: 'Signed out' }
  end

  private

  def exchange_request_token(request_token, oauth_verifier)
    token = OAuth::RequestToken.new(consumer, request_token['token'], request_token['secret'])
    token.get_access_token(oauth_verifier: oauth_verifier, oauth_callback: finish_sessions_url)
  end

  def consumer
    OAuth::Consumer.new(Rails.application.secrets.twitter_consumer_key,
                        Rails.application.secrets.twitter_consumer_secret,
                        site: 'https://api.twitter.com',
                        scheme: :header)
  end

  def next_path
    session[:next_path] || root_path
  end

  def require_anonymous
    redirect_to root_path if current_user
  end

  def require_request_token
    flash[:warning] = 'Starting Sign in with Twitter flow.'
    redirect_to new_sessions_path unless session[:request_token]
  end

  def require_known_request_token
    flash[:warning] = 'Something went wrong. Starting over.'
    redirect_to new_sessions_path unless session[:request_token]['token'] == params[:oauth_token]
  end

  def require_not_denied
    return unless params[:denied]
    flash[:warning] = 'Twitter access is needed to sign in.'
    redirect_to new_sessions_path
  end
end
