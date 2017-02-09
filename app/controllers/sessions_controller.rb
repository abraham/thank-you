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
    request_token = session[:request_token]

    token = OAuth::RequestToken.new(consumer, request_token['token'], request_token['secret'])
    access_token = token.get_access_token(oauth_verifier: params[:oauth_verifier],
                                          oauth_callback: finish_sessions_url)
    twitter_user = etl_user(access_token.token, access_token.secret)

    # TODO: move this to a class method on User
    user = User.find_by(twitter_id: twitter_user.id) || User.new(twitter_id: twitter_user.id)
    user.name = twitter_user.name
    user.data = twitter_user.to_hash
    user.screen_name = twitter_user.screen_name
    user.avatar_url = twitter_user.profile_image_uri_https
    user.email = twitter_user.email
    user.access_token = access_token.token
    user.access_token_secret = access_token.secret
    user.save

    path = next_path
    reset_session
    session[:user_id] = user.id

    redirect_to path
  end

  def destroy
    reset_session
    redirect_to root_path, flash: { notice: 'Signed out.' }
  end

  private

  def consumer
    OAuth::Consumer.new(Rails.application.secrets.twitter_consumer_key,
                        Rails.application.secrets.twitter_consumer_secret,
                        site: 'https://api.twitter.com',
                        scheme: :header)
  end

  def consumer_with_request_token(consumer, token, secret)
    OAuth::RequestToken.new(consumer, token, secret)
  end

  def etl_user(token, secret)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      config.access_token = token
      config.access_token_secret = secret
    end
    client.user(include_email: true)
  end

  def next_path
    session[:next_path] || root_path
  end

  def require_anonymous
    redirect_to root_path if current_user
  end

  def require_request_token
    flash[:warning] = 'You have to start the Sign in with Twitter flow before finishing it.'
    redirect_to new_sessions_path unless session[:request_token]
  end

  def require_known_request_token
    flash[:warning] = 'Sign in with Twitter details do not match. Starting over.'
    redirect_to new_sessions_path unless session[:request_token]['token'] == params[:oauth_token]
  end

  def require_not_denied
    return unless params[:denied]
    flash[:warning] = 'To sign in you must allow access to your Twitter account.'
    redirect_to new_sessions_path
  end
end
