require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @token = 'Z6eEdO8MOmk394WozF5oKyuAv855l4Mlqo7hhlSLik'
    @secret = 'Kd75W4OQfb2oJTV0vzGzeXftVAwgMnEK9MumzYcM'
    @twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
  end

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
    stub_request_token

    post sessions_url

    assert_equal({ token: @token, secret: @secret }, session[:request_token])
    assert_redirected_to "https://api.twitter.com/oauth/authorize?oauth_token=#{@token}"
  end

  test 'should get finish' do
    stub_request_token
    post sessions_url
    stub_access_token
    stub_verify_credentials

    assert_difference 'User.count', 1 do
      get finish_sessions_url params: { oauth_token: @token, oauth_verifier: 'verifier' }
    end

    user = User.find(session[:user_id])
    assert_nil session[:request_token]
    assert_equal session[:user_id], User.last.id
    assert_equal user.screen_name, @twitter_user[:screen_name]
    assert_equal user.twitter_id, @twitter_user[:id].to_s
    assert_equal user.email, @twitter_user[:email]
    assert_redirected_to root_url
  end

  test 'should redirect to local referrer location' do
    deed = create(:deed)

    get new_sessions_url, headers: { Referer: deed_url(deed) }
    assert_response :success
    assert_equal deed_url(deed), @response.cookies['last_referrer']

    sign_in
    user = User.find_by(twitter_id: @twitter_user[:id].to_s)

    assert_nil session['request_token_id']
    assert_equal session['user_id'], user.id
    assert_equal user.screen_name, @twitter_user[:screen_name]
    assert_redirected_to deed_url(deed)
  end

  test 'should not redirect to remote referrer location' do
    get new_sessions_url, headers: { Referer: 'http://other.com/foo/bar' }
    assert_response :success
    assert_equal 'http://other.com/foo/bar', @response.cookies['last_referrer']

    sign_in
    user = User.find_by(twitter_id: @twitter_user[:id].to_s)

    assert_nil session['request_token']
    assert_equal session['user_id'], user.id
    assert_equal user.screen_name, @twitter_user[:screen_name]
    assert_redirected_to root_url
  end

  test 'should get create with returning user' do
    # TODO
  end

  test 'should get create with auth denied' do
    # TODO
  end

  test 'should delete destroy' do
    sign_in

    assert_not_nil session[:user_id]
    delete sessions_url
    assert_redirected_to root_url
    assert_nil session[:user_id]
    assert_equal flash[:notice], 'Signed out.'
  end

  def stub_request_token
    params = [
      "oauth_token=#{@token}",
      "oauth_token_secret=#{@secret}",
      'oauth_callback_confirmed=true'
    ]
    stub_request(:post, 'https://api.twitter.com/oauth/request_token')
      .to_return(status: 200, body: params.join('&'))
  end

  def stub_access_token
    params = [
      'oauth_token=6253282-eWudHldSbIaelX7swmsiHImEL4KinwaGloHANdrY',
      'oauth_token_secret=2EEfA6BG3ly3sR3RjE0IBSnlQu4ZrUzPiYKmrkVU',
      "user_id=#{@twitter_user[:id]}",
      "screen_name=#{@twitter_user[:screen_name]}"
    ]
    stub_request(:post, 'https://api.twitter.com/oauth/access_token')
      .to_return(status: 200, body: params.join('&'))
  end

  def stub_verify_credentials
    stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true')
      .to_return(status: 200, body: @twitter_user.to_json)
  end

  def start_sign_in
    stub_request_token
    post sessions_url
  end

  def finish_sign_in
    stub_access_token
    stub_verify_credentials
    get finish_sessions_url params: { oauth_token: @token, oauth_verifier: 'verifier' }
  end

  def sign_in
    start_sign_in
    finish_sign_in
  end
end
