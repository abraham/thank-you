require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @thank = create(:thank, user: @user)
  end

  test 'POST /links' do
    assert_routing({ path: 'thanks/123/links', method: :post }, { controller: 'links', action: 'create', thank_id: '123' })
  end

  test 'GET /links/new' do
    assert_routing({ path: 'thanks/123/links/new', method: :get }, { controller: 'links', action: 'new', thank_id: '123' })
  end

  test 'should redirect get new to sessions new' do
    get new_thank_link_url(@thank)
    assert_redirected_to new_session_url
  end

  test 'should get new' do
    cookies[:user_id] = @user.id
    get new_thank_link_url(@thank)
    assert_response :success
  end

  test 'should redirect post create to sessions new' do
    post thank_links_url(@thank)
    assert_redirected_to new_session_url
  end

  test 'should post create' do
    cookies[:user_id] = @user.id

    assert_difference 'Link.count', 1 do
      post thank_links_url @thank, params: { link: { text: 'foo', url: 'foo', thank_id: @thank.id } }
    end

    assert_redirected_to thank_path(@thank)
    assert_equal 'Link was successfully created.', flash[:notice]
  end
end
