require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @thank = create(:thank, user: @user)
  end

  test 'should get new' do
    get links_new_url(@thank)
    assert_response :success
  end

  test 'should post create' do
    cookies[:user_id] = @user.id

    assert_difference 'Link.count', 1 do
      post links_create_url @thank, params: { link: { text: 'foo', url: 'foo' } }
    end

    assert_redirected_to thanks_show_path(@thank)
    assert_equal 'Link was successfully created.', flash[:notice]
  end
end
