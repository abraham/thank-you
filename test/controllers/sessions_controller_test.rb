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

  test 'should get new' do
    get new_sessions_url

    assert_response :success
    assert_select 'form input[type=submit][value="Sign in with Twitter"]'
    assert_nil session['request_token']
  end

  test 'should post start' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    stub_request_token(token, secret)

    post sessions_url

    assert_equal({ token: token, secret: secret }, session[:request_token])
    assert_redirected_to "https://api.twitter.com/oauth/authorize?oauth_token=#{token}"
  end

  test 'should get finish' do
    token = TwitterHelper::TWITTER_TOKEN
    secret = TwitterHelper::TWITTER_SECRET
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    stub_request_token(token, secret)
    post sessions_url
    stub_access_token(twitter_user[:id], twitter_user[:screen_name])
    stub_verify_credentials(twitter_user)

    assert_difference 'User.count', 1 do
      get finish_sessions_url params: { oauth_token: token, oauth_verifier: 'verifier' }
    end

    user = User.find(session[:user_id])
    assert_nil session[:request_token]
    assert_equal session[:user_id], User.last.id
    assert_equal user.screen_name, twitter_user[:screen_name]
    assert_equal user.twitter_id, twitter_user[:id].to_s
    assert_equal user.email, twitter_user[:email]
    assert_redirected_to root_url
  end

  test 'should redirect to local referrer location' do
    deed = create(:deed)

    get new_sessions_url, headers: { Referer: deed_url(deed) }
    assert_response :success
    assert_equal deed_url(deed), @response.cookies['last_referrer']

    user = sign_in_as :user

    assert_nil session['request_token_id']
    assert_equal session['user_id'], user.id
    assert_redirected_to deed_url(deed)
  end

  test 'should not redirect to remote referrer location' do
    get new_sessions_url, headers: { Referer: 'http://other.com/foo/bar' }
    assert_response :success
    assert_equal 'http://other.com/foo/bar', @response.cookies['last_referrer']

    user = sign_in_as :user

    assert_nil session['request_token']
    assert_equal session['user_id'], user.id
    assert_redirected_to root_url
  end

  test 'should get create with returning user' do
    # TODO
  end

  test 'should get create with auth denied' do
    # TODO
  end

  test 'should delete destroy' do
    sign_in_as :user

    assert_not_nil session[:user_id]
    delete sessions_url
    assert_redirected_to root_url
    assert_nil session[:user_id]
    assert_equal flash[:notice], 'Signed out.'
  end
end
