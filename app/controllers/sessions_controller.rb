class SessionsController < ApplicationController
  def new
    twitter_request_token = consumer.get_request_token
    request_token = RequestToken.create(token: twitter_request_token.token,
                                        secret: twitter_request_token.secret)
    cookies[:request_token_id] = request_token.id

    redirect_to twitter_request_token.authorize_url
  end

  def create
    # validate request_token
    # Get request_token from DB
    # Exchange for access_token
    # Get user profile
    # Save user to DB
    # Set user session
    # Redirect to origin
  end

  def destroy
    # destroy user session
    # redirect to homepage
  end

  private

  def consumer
    OAuth::Consumer.new(Rails.application.secrets.twitter_consumer_key,
                        Rails.application.secrets.twitter_consumer_secret,
                        site: 'https://api.twitter.com',
                        scheme: :header)
  end
end
