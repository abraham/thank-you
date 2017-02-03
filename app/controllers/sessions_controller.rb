class SessionsController < ApplicationController
  before_action :cache_last_referrer, only: [:new]

  def new
    # TODO: require not be signed in
  end

  def create
    id = SecureRandom.uuid
    twitter_request_token = consumer.get_request_token(oauth_callback: finish_session_url)
    request_token = RequestToken.create(id: id,
                                        token: twitter_request_token.token,
                                        secret: twitter_request_token.secret)
    cookies[:request_token_id] = request_token.id
    cookies.delete(:user_id)

    redirect_to twitter_request_token.authorize_url
  end

  def finish
    request_token = RequestToken.find(cookies[:request_token_id])
    cookies.delete(:request_token_id)

    # TODO: handle authorization rejection
    # TODO: Test this failure
    raise unless request_token.token == params[:oauth_token]

    token = OAuth::RequestToken.new(consumer, request_token.token, request_token.secret)

    access_token = token.get_access_token(oauth_verifier: params[:oauth_verifier],
                                          oauth_callback: finish_session_url)

    request_token.delete
    twitter_user = etl_user(access_token.token, access_token.secret)

    user = User.find_by(twitter_id: twitter_user.id) || User.new(twitter_id: twitter_user.id)
    user.name = twitter_user.name
    user.data = twitter_user.to_hash
    user.screen_name = twitter_user.screen_name
    user.avatar_url = twitter_user.profile_image_uri_https
    user.access_token = access_token.token
    user.access_token_secret = access_token.secret
    user.save

    cookies[:user_id] = user.id

    redirect_to parsed_local_referrer_path and cookies.delete(:last_referrer)
  end

  def destroy
    cookies.delete(:user_id)
    flash[:notice] = 'Signed out.'
    redirect_to root_path
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
      config.consumer_key    = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      config.access_token        = token
      config.access_token_secret = secret
    end
    client.user
  end

  def parsed_local_referrer_path
    if cookies[:last_referrer] && cookies[:last_referrer].starts_with?(root_url)
      URI.parse(cookies[:last_referrer]).path
    else
      '/'
    end
  end

  def cache_last_referrer
    cookies[:last_referrer] = request.referrer
  end
end
