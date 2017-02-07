require 'test_helper'

class DeedsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @default_admin_twitter_ids = AppConfig.admin_twitter_ids
  end

  def teardown
    AppConfig.admin_twitter_ids = @default_admin_twitter_ids
  end

  test 'GET /' do
    assert_routing({ path: '/', method: :get }, { controller: 'deeds', action: 'index' })
  end

  test 'POST /deeds' do
    assert_routing({ path: 'deeds', method: :post }, { controller: 'deeds', action: 'create' })
  end

  test 'GET /deeds/new' do
    assert_routing({ path: 'deeds/new', method: :get }, { controller: 'deeds', action: 'new' })
  end

  test 'GET /deeds/:id' do
    assert_routing({ path: 'deeds/123', method: :get }, { controller: 'deeds', action: 'show', id: '123' })
  end

  test 'should get root' do
    get deeds_path
    assert_redirected_to root_path
  end

  test 'should get deeds' do
    get root_path
    assert_response :success
  end

  test 'should get deeds show' do
    deed = create(:deed)
    get deed_path(deed)
    assert_response :success
  end

  test 'should redirect get deeds new to sessions new' do
    get new_deed_path
    assert_redirected_to new_sessions_url
  end

  test 'should redirect post deeds create to sessions new' do
    post deeds_path
    assert_redirected_to new_sessions_url
  end

  test 'should redirect get deeds new to get deeds as a user' do
    user = create(:user)
    cookies[:user_id] = user.id
    get new_deed_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:error]
  end

  test 'should redirect post deeds create to get deeds as a user' do
    user = create(:user)
    cookies[:user_id] = user.id
    post deeds_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:error]
  end

  test 'should allow admins to get new' do
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id.to_s]
    cookies[:user_id] = user.id
    get new_deed_path
    assert_response :success
  end

  test 'should allow admins to post create' do
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id]
    cookies[:user_id] = user.id
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deeds: { text: Faker::Lorem.sentence(3), name: Faker::Internet.user_name } }
    end
    assert_redirected_to deed_path(Deed.last)
    assert_equal 'deed you created successfully.', flash[:notice]
  end
end
