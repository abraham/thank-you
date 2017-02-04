require 'test_helper'

class ThanksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @default_admin_twitter_ids = AppConfig.admin_twitter_ids
  end

  def teardown
    AppConfig.admin_twitter_ids = @default_admin_twitter_ids
  end

  test 'GET /' do
    assert_routing({ path: '/', method: :get }, { controller: 'thanks', action: 'index' })
  end

  test 'POST /thanks' do
    assert_routing({ path: 'thanks', method: :post }, { controller: 'thanks', action: 'create' })
  end

  test 'GET /thanks/new' do
    assert_routing({ path: 'thanks/new', method: :get }, { controller: 'thanks', action: 'new' })
  end

  test 'GET /thanks/:id' do
    assert_routing({ path: 'thanks/123', method: :get }, { controller: 'thanks', action: 'show', id: '123' })
  end

  test 'should get root' do
    get thanks_path
    assert_redirected_to root_path
  end

  test 'should get thanks' do
    get root_path
    assert_response :success
  end

  test 'should get thanks show' do
    thank = create(:thank)
    get thank_path(thank)
    assert_response :success
  end

  test 'should redirect get thanks new to sessions new' do
    get new_thank_path
    assert_redirected_to new_session_url
  end

  test 'should redirect post thanks create to sessions new' do
    post thanks_path
    assert_redirected_to new_session_url
  end

  test 'should redirect get thanks new to get thanks as a user' do
    user = create(:user)
    cookies[:user_id] = user.id
    get new_thank_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:error]
  end

  test 'should redirect post thanks create to get thanks as a user' do
    user = create(:user)
    cookies[:user_id] = user.id
    post thanks_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:error]
  end

  test 'should allow admins to get new' do
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id.to_s]
    cookies[:user_id] = user.id
    get new_thank_path
    assert_response :success
  end

  test 'should allow admins to post create' do
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id]
    cookies[:user_id] = user.id
    assert_difference 'Thank.count', 1 do
      post thanks_path, params: { thanks: { text: Faker::Lorem.sentence(3), name: Faker::Internet.user_name } }
    end
    assert_redirected_to thank_path(Thank.last)
    assert_equal 'Thank you created successfully.', flash[:notice]
  end
end
