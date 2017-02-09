require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'factory_girl'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  include FactoryGirl::Syntax::Methods
  FactoryGirl.find_definitions
end

module SessionHelper
  def start_sign_in(token, secret)
    stub_request_token(token, secret)
    post sessions_url
  end

  def finish_sign_in(token, twitter_user)
    stub_access_token(twitter_user[:id], twitter_user[:screen_name])
    stub_verify_credentials(twitter_user)
    get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }
  end

  def sign_in_as(user_type)
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id] if user_type == :admin
    start_sign_in(TwitterHelper::TWITTER_TOKEN, TwitterHelper::TWITTER_SECRET)
    finish_sign_in(TwitterHelper::TWITTER_TOKEN, user.data)
    user
  end
end

module TwitterHelper
  TWITTER_TOKEN = 'Z6eEdO8MOmk394WozF5oKyuAv855l4Mlqo7hhlSLik'.freeze
  TWITTER_SECRET = 'Kd75W4OQfb2oJTV0vzGzeXftVAwgMnEK9MumzYcM'.freeze

  def stub_request_token(token, secret)
    params = [
      "oauth_token=#{token}",
      "oauth_token_secret=#{secret}",
      'oauth_callback_confirmed=true'
    ]
    stub_request(:post, 'https://api.twitter.com/oauth/request_token')
      .to_return(status: 200, body: params.join('&'))
  end

  def stub_access_token(user_id, screen_name)
    params = [
      'oauth_token=6253282-eWudHldSbIaelX7swmsiHImEL4KinwaGloHANdrY',
      'oauth_token_secret=2EEfA6BG3ly3sR3RjE0IBSnlQu4ZrUzPiYKmrkVU',
      "user_id=#{user_id}",
      "screen_name=#{screen_name}"
    ]
    stub_request(:post, 'https://api.twitter.com/oauth/access_token')
      .to_return(status: 200, body: params.join('&'))
  end

  def stub_verify_credentials(twitter_user)
    stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true')
      .to_return(status: 200, body: twitter_user.to_json)
  end

  def stub_statuses_update(tweet, status, in_reply_to_status_id: nil)
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { in_reply_to_status_id: in_reply_to_status_id, status: status })
      .to_return(status: 200, body: tweet.to_json)
  end
end

class ActionDispatch::IntegrationTest
  include TwitterHelper
  include SessionHelper
end
