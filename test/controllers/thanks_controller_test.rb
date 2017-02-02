require 'test_helper'

class ThanksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @default_admin_twitter_ids = AppConfig.admin_twitter_ids
  end

  def teardown
    AppConfig.admin_twitter_ids = @default_admin_twitter_ids
  end

  test 'should get root' do
    get thanks_path
    assert_response :success
  end

  test 'should get thanks' do
    get root_path
    assert_response :success
  end

  test 'should get thanks show' do
    thank = create(:thank)
    get thanks_show_path(thank)
    assert_response :success
  end

  test 'should redirect get thanks new to sessions new' do
    get thanks_new_path
    assert_redirected_to sessions_new_url
  end

  test 'should redirect post thanks create to sessions new' do
    post thanks_create_path
    assert_redirected_to sessions_new_url
  end

  test 'should redirect get thanks new to get thanks as a user' do
    user = create(:user)
    cookies[:user_id] = user.id
    get thanks_new_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:error]
  end

  test 'should redirect post thanks create to get thanks as a user' do
    user = create(:user)
    cookies[:user_id] = user.id
    post thanks_create_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:error]
  end

  test 'should allow admins to get new' do
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id.to_s]
    cookies[:user_id] = user.id
    get thanks_new_path
    assert_response :success
  end

  test 'should allow admins to post create' do
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id]
    cookies[:user_id] = user.id
    assert_difference 'Thank.count', 1 do
      post thanks_create_path, params: { thanks: { text: Faker::Lorem.sentence(3), name: Faker::Internet.user_name } }
    end
    assert_redirected_to thanks_show_path(Thank.last)
    assert_equal 'Thank you created successfully.', flash[:notice]
  end
end
