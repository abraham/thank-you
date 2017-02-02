class SessionsController < ApplicationController
  def new
    # TODO: require not be signed in
  end

  def start
    twitter_request_token = consumer.get_request_token(oauth_callback: sessions_finish_url)
    request_token = RequestToken.create(token: twitter_request_token.token,
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

    request_token.delete

    access_token = token.get_access_token(oauth_verifier: params[:oauth_verifier],
                                          oauth_callback: sessions_start_url)

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

    redirect_to root_path
  end

  def destroy
    cookies.delete(:user_id)
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
end
