# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'GET /sessions/finish' do
    assert_routing({ path: '/sessions/finish', method: :get }, controller: 'sessions', action: 'finish')
  end

  test 'GET /sessions/new' do
    assert_routing({ path: '/sessions/new', method: :get }, controller: 'sessions', action: 'new')
  end

  test 'DELET /sessions' do
    assert_routing({ path: '/sessions', method: :delete }, controller: 'sessions', action: 'destroy')
  end

  test 'POST /sessions' do
    assert_routing({ path: '/sessions', method: :post }, controller: 'sessions', action: 'create')
  end

  test '#new should return a form' do
    get new_sessions_url

    assert_response :success
    assert_select "form[action=\"#{sessions_path}\"]" do
      assert_select 'input[type=submit][value="Sign in with Twitter"]'
    end
    assert_nil session['request_token']
  end

  test '#new should redirect a user' do
    sign_in_as :user
    get new_sessions_url

    assert_redirected_to root_url
  end

  test '#finish requires request_token in session' do
    token = TwitterHelper::TWITTER_TOKEN
    get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }

    assert_redirected_to new_sessions_url
    assert_equal 'Starting Sign in with Twitter flow.', flash[:warning]
  end

  test '#finish requires known request_token' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    stub_request_token(token, secret)
    post sessions_url

    get finish_sessions_url params: { oauth_token: 'different-token', oauth_verifier: 'verifier' }

    assert_redirected_to new_sessions_url
    assert_equal 'Something went wrong. Starting over.', flash[:warning]
  end

  test '#create starts session flow' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    stub_request_token(token, secret)
    get new_sessions_url
    session_id = session.id

    post sessions_url

    assert_not_equal session_id, session.id
    assert_equal({ token: token, secret: secret }, session[:request_token])
    assert_redirected_to "https://api.twitter.com/oauth/authorize?oauth_token=#{token}"
  end

  test '#finish signs in new users' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    stub_access_token(twitter_user[:id], twitter_user[:screen_name])
    stub_verify_credentials(twitter_user)
    start_sign_in token, secret
    session_id = session.id

    assert_difference 'User.count', 1 do
      get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }
    end

    user = User.find(session[:user_id])
    assert_not_equal session_id, session.id
    assert_nil session[:request_token]
    assert_equal session[:user_id], User.last.id
    assert_equal user.screen_name, twitter_user[:screen_name]
    assert_equal user.twitter_id, twitter_user[:id].to_s
    assert_equal user.email, twitter_user[:email]
    assert_redirected_to root_url
  end

  test '#finish signs in existing users' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    old_user = create(:user)
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    twitter_user[:id] = old_user.data['id']
    twitter_user[:id_str] = old_user.data['id_str']
    stub_access_token(twitter_user[:id], twitter_user[:screen_name])
    stub_verify_credentials(twitter_user)
    start_sign_in token, secret
    session_id = session.id

    assert_no_difference 'User.count' do
      get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }
    end

    user = User.find(session[:user_id])
    assert_not_equal session_id, session.id
    assert_equal user.id, old_user.id
    assert_equal user.twitter_id, old_user.twitter_id
    assert_not_equal user.screen_name, old_user.screen_name
    assert_not_equal user.email, old_user.email
    assert_nil session[:request_token]
    assert_equal session[:user_id], User.last.id
    assert_equal user.screen_name, twitter_user[:screen_name]
    assert_equal user.twitter_id, twitter_user[:id].to_s
    assert_equal user.email, twitter_user[:email]
    assert_redirected_to root_url
  end

  test '#finish does not change User.status' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    user = create(:user, status: :disabled)
    stub_access_token(user[:twitter_id], user[:screen_name])
    stub_verify_credentials(user.data)
    start_sign_in token, secret
    get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }
    user = User.find(session[:user_id])
    assert user.disabled?
    assert_redirected_to root_url
  end

  test '#finish should handle being denied access' do
    get finish_sessions_url params: { denied: 'D_gvkwAAAAAAy9zXAAABWhooOmA' }

    assert_redirected_to new_sessions_url
    assert_equal 'Twitter access is needed to sign in.', flash[:warning]
  end

  test '#finish returns to previous location' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    stub_access_token(twitter_user[:id], twitter_user[:screen_name])
    stub_verify_credentials(twitter_user)
    deed = create(:deed)
    get new_deed_thank_url(deed)
    assert_redirected_to new_sessions_url
    assert_equal new_deed_thank_path(deed), session['next_path']
    start_sign_in token, secret
    get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }
    assert_redirected_to new_deed_thank_url(deed)
    assert_nil session['next_path']
    assert session['user_id']
  end

  test '#destroy should sign out the user' do
    sign_in_as :user
    session_id = session.id

    assert_not_nil session[:user_id]
    delete sessions_url
    assert_not_equal session_id, session.id
    assert_redirected_to root_url
    assert_nil session[:user_id]
    assert_equal flash[:notice], 'Signed out'
  end
end
