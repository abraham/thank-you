require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @thank = create(:thank, user: @user)
  end

  test 'should redirect get new to sessions new' do
    get links_new_url(@thank)
    assert_redirected_to sessions_new_url
  end

  test 'should get new' do
    cookies[:user_id] = @user.id
    get links_new_url(@thank)
    assert_response :success
  end

  test 'should redirect post create to sessions new' do
    post links_create_url(@thank)
    assert_redirected_to sessions_new_url
  end

  test 'should post create' do
    cookies[:user_id] = @user.id

    assert_difference 'Link.count', 1 do
      post links_create_url @thank, params: { link: { text: 'foo', url: 'foo' } }
    end

    assert_redirected_to thank_path(@thank)
    assert_equal 'Citation was successfully created.', flash[:notice]
  end
end
