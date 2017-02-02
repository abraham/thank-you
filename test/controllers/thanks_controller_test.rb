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
end
