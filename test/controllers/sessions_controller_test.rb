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
    assert_equal 'You have to start the Sign in with Twitter flow before finishing it.', flash[:warning]
  end

  test '#finish requires known request_token' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    stub_request_token(token, secret)
    post sessions_url

    get finish_sessions_url params: { oauth_token: 'different-token', oauth_verifier: 'verifier' }

    assert_redirected_to new_sessions_url
    assert_equal 'Sign in with Twitter details do not match. Starting over.', flash[:warning]
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
    stub_request_token(token, secret)
    post sessions_url
    stub_access_token(twitter_user[:id], twitter_user[:screen_name])
    stub_verify_credentials(twitter_user)
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
    stub_request_token(token, secret)
    post sessions_url
    stub_access_token(twitter_user[:id], twitter_user[:screen_name])
    stub_verify_credentials(twitter_user)
    session_id = session.id

    assert_difference 'User.count', 0 do
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

  test '#finish should handle being denied access' do
    get finish_sessions_url params: { denied: 'D_gvkwAAAAAAy9zXAAABWhooOmA' }

    assert_redirected_to new_sessions_url
    assert_equal 'To sign in you must allow access to your Twitter account.', flash[:warning]
  end

  test '#finish returns to previous location' do
    deed = create(:deed)
    get new_deed_thank_url(deed)
    assert_redirected_to new_sessions_url

    assert_equal new_deed_thank_path(deed), session['next_path']

    get new_sessions_url
    assert_response :success

    user = sign_in_as :user

    assert_nil session['next_path']
    assert_equal session['user_id'], user.id
    assert_redirected_to new_deed_thank_url(deed)
  end

  test '#destroy should sign out the user' do
    sign_in_as :user
    session_id = session.id

    assert_not_nil session[:user_id]
    delete sessions_url
    assert_not_equal session_id, session.id
    assert_redirected_to root_url
    assert_nil session[:user_id]
    assert_equal flash[:notice], 'Signed out.'
  end
end
