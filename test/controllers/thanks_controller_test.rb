require 'test_helper'

class ThanksControllerTest < ActionDispatch::IntegrationTest
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

  test 'should redirect post thanks create to  get thanks as a user' do
    user = create(:user)
    cookies[:user_id] = user.id
    post thanks_create_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:error]
  end
end
