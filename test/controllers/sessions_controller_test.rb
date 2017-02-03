require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get new_session_url
    assert_response :success
  end

  test 'should post start' do
    token = 'Z6eEdO8MOmk394WozF5oKyuAv855l4Mlqo7hhlSLik'
    stub_request_token(token)
    cookies[:user_id] = 'foo'
    assert_difference 'RequestToken.count', 1 do
      post session_url
    end
    assert_equal @response.cookies['request_token_id'], RequestToken.last.id
    assert @response.cookies['user_id'].nil?
    assert_equal token, RequestToken.last.token
    assert_redirected_to "https://api.twitter.com/oauth/authorize?oauth_token=#{token}"
  end

  test 'should get finish' do
    @twitter_user = Faker::Twitter.user
    stub_access_token
    stub_verify_credentials
    request_token = create(:request_token)
    cookies[:request_token_id] = request_token.id
    request_token = RequestToken.last

    assert_difference 'RequestToken.count', -1 do
      assert_difference 'User.count', 1 do
        get edit_session_url params: { oauth_token: request_token.token, oauth_verifier: 'verifier' }
      end
    end
    assert @response.cookies['request_token_id'].nil?
    assert_equal @response.cookies['user_id'], User.last.id
    assert_equal User.last.screen_name, @twitter_user[:screen_name]
    assert_equal User.last.twitter_id, @twitter_user[:id].to_s
    assert_redirected_to root_url
  end

  test 'should redirect to local referrer location' do
    @twitter_user = Faker::Twitter.user
    stub_access_token
    stub_verify_credentials
    request_token = create(:request_token)
    cookies[:request_token_id] = request_token.id
    thank = create(:thank)

    get new_session_url, headers: { Referer: thank_url(thank) }
    assert_response :success
    assert_equal thank_url(thank), @response.cookies['last_referrer']
    request_token = RequestToken.last

    assert_difference 'RequestToken.count', -1 do
      assert_difference 'User.count', 1 do
        get edit_session_url params: { oauth_token: request_token.token, oauth_verifier: 'verifier' }
      end
    end

    user = User.find_by(twitter_id: @twitter_user[:id].to_s)

    assert @response.cookies['request_token_id'].nil?
    assert_equal @response.cookies['user_id'], user.id
    assert_equal user.screen_name, @twitter_user[:screen_name]
    assert_redirected_to thank_url(thank)
  end

  test 'should not redirect to remote referrer location' do
    @twitter_user = Faker::Twitter.user
    stub_access_token
    stub_verify_credentials
    request_token = create(:request_token)
    cookies[:request_token_id] = request_token.id

    get new_session_url, headers: { Referer: 'http://other.com/foo/bar' }
    assert_response :success
    assert_equal 'http://other.com/foo/bar', @response.cookies['last_referrer']
    request_token = RequestToken.last

    assert_difference 'RequestToken.count', -1 do
      assert_difference 'User.count', 1 do
        get edit_session_url params: { oauth_token: request_token.token, oauth_verifier: 'verifier' }
      end
    end

    user = User.find_by(twitter_id: @twitter_user[:id].to_s)

    assert @response.cookies['request_token_id'].nil?
    assert_equal @response.cookies['user_id'], user.id
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
    user = create(:user)
    cookies[:user_id] = user.id
    delete session_url
    assert_redirected_to root_url
    assert @response.cookies[:user_id].nil?
    assert_equal flash[:notice], 'Signed out.'
  end

  def stub_request_token(token)
    params = [
      "oauth_token=#{token}",
      'oauth_token_secret=Kd75W4OQfb2oJTV0vzGzeXftVAwgMnEK9MumzYcM',
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
    stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json')
      .to_return(status: 200, body: @twitter_user.to_json)
  end
end
