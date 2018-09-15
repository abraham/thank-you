# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'factory_bot'
require 'rails/test_help'
require 'webmock/minitest'

module SessionsHelper
  def start_sign_in(token, secret)
    stub_request_token(token, secret)
    post sessions_url
  end

  def finish_sign_in(token, twitter_user)
    stub_access_token(twitter_user['id'], twitter_user['screen_name'])
    stub_verify_credentials(twitter_user)
    get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }
  end

  def sign_in_as(role, status = :active)
    sign_out
    return if role == :anonymous

    user = create(:user, role, status)
    start_sign_in(TwitterHelper::TWITTER_TOKEN, TwitterHelper::TWITTER_SECRET)
    finish_sign_in(TwitterHelper::TWITTER_TOKEN, user.data)
    user
  end

  def sign_out
    delete sessions_url
  end
end

module TwitterHelper
  TWITTER_SECRET = 'Kd75W4OQfb2oJTV0vzGzeXftVAwgMnEK9MumzYcM'
  TWITTER_TOKEN = 'Z6eEdO8MOmk394WozF5oKyuAv855l4Mlqo7hhlSLik'

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

  def stub_statuses_show(tweet)
    stub_request(:get, "https://api.twitter.com/1.1/statuses/show/#{tweet[:id]}.json")
      .to_return(status: 200, body: tweet.to_json)
  end

  def stub_unauthorized
    error = { errors: [{ message: 'Could not authenticate you', code: 135 }] }
    stub_request(:any, /api.twitter.com/)
      .to_return(status: [401, 'Unauthorized'], body: error.to_json)
  end

  def stub_over_140
    error = { errors: [{ message: 'Status is over 140 characters', code: 135 }] }
    stub_request(:any, /api.twitter.com/)
      .to_return(status: [403, 'Forbidden'], body: error.to_json)
  end

  def stub_rate_limit
    error = { errors: [{ message: 'Rate limit exceeded', code: 88 }] }
    stub_request(:any, /api.twitter.com/)
      .to_return(status: [420, 'Enhance Your Calm'], body: error.to_json)
  end

  def stub_status_not_found
    error = { errors: [{ message: 'No status found with that ID.', code: 133 }] }
    stub_request(:any, /api.twitter.com/)
      .to_return(status: [404, 'Not found'], body: error.to_json)
  end
end

module GoogleHelper
  GOOGLE_API_KEY = 'fake_key'
  GOOGLE_TOKEN = 'secret-token'

  def stub_add_topic(token, topic)
    stub_request(:post, 'https://iid.googleapis.com/iid/v1:batchAdd')
      .with(headers: {
              'Authorization' => "key=#{GOOGLE_API_KEY}"
            },
            body: {
              registration_tokens: [token],
              to: "/topics/#{topic}"
            })
      .to_return(status: 200, body: { results: [{}] }.to_json)
  end

  def stub_remove_topic(token, topic)
    stub_request(:post, 'https://iid.googleapis.com/iid/v1:batchRemove')
      .with(headers: {
              'Authorization' => "key=#{GOOGLE_API_KEY}"
            },
            body: {
              registration_tokens: [token],
              to: "/topics/#{topic}"
            })
      .to_return(status: 200, body: { results: [{}] }.to_json)
  end

  def stub_topic_info(token, topics)
    data = {
      connectDate: '2017-03-06',
      application: 'com.chrome.macosx',
      subtype: 'wp:http://localhost:5000/#A869D94E-5ADE-4F90-A488-78C0F09F1-V2',
      authorizedEntity: '133536989471',
      rel: {
        topics: Hash[topics.map { |topic| [topic, { addDate: '2017-03-06' }] }]
      },
      connectionType: 'WIFI',
      platform: 'WEBPUSH'
    }

    stub_request(:get, "https://iid.googleapis.com/iid/info/#{token}?details=true")
      .with(headers: { 'Authorization' => "key=#{GOOGLE_API_KEY}" })
      .to_return(status: 200, body: data.to_json)
  end

  def stub_send_push(topic, deed)
    stub_request(:post, 'https://fcm.googleapis.com/fcm/send')
      .with(body: {
        to: "/topics/#{topic}",
        data: {
          version: 1,
          topic: topic,
          notification: {
            title: "@#{deed.user.screen_name} added a new Deed",
            body: deed.display_text,
            icon: deed.user.avatar_url,
            click_action: deed_url(deed)
          }
        }
      }.to_json,
            headers: { 'Authorization' => 'key=fake_key' })
      .to_return(status: 200, body: '')
  end
end

module ActionDispatch
  class IntegrationTest
    include SessionsHelper
    include GoogleHelper
    include TwitterHelper
  end
end

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include GoogleHelper
    include TwitterHelper

    FactoryBot.find_definitions
  end
end
