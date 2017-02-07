require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @deed = create(:deed, user: @user)
  end

  test 'POST /links' do
    assert_routing({ path: 'deeds/123/links', method: :post }, { controller: 'links', action: 'create', deed_id: '123' })
  end

  test 'GET /links/new' do
    assert_routing({ path: 'deeds/123/links/new', method: :get }, { controller: 'links', action: 'new', deed_id: '123' })
  end

  test 'should redirect get new to sessions new' do
    get new_deed_link_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test 'should get new' do
    cookies[:user_id] = @user.id
    get new_deed_link_url(@deed)
    assert_response :success
  end

  test 'should redirect post create to sessions new' do
    post deed_links_url(@deed)
    assert_redirected_to new_sessions_url
  end

  test 'should post create' do
    cookies[:user_id] = @user.id

    assert_difference 'Link.count', 1 do
      post deed_links_url @deed, params: { link: { text: 'foo', url: 'foo', deed_id: @deed.id } }
    end

    assert_redirected_to deed_path(@deed)
    assert_equal 'Link was successfully created.', flash[:notice]
  end
end
