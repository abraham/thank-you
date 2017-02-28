require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @deed = create(:deed, user: create(:user))
  end

  test 'POST /links' do
    assert_routing({ path: 'deeds/123/links', method: :post }, controller: 'links', action: 'create', deed_id: '123')
  end

  test 'GET /links/new' do
    assert_routing({ path: 'deeds/123/links/new', method: :get }, controller: 'links', action: 'new', deed_id: '123')
  end

  test '#new requires auth' do
    get new_deed_link_url(@deed)
    assert_redirected_to new_sessions_url
    assert_equal 'You must be signed in to do that', flash[:warning]
  end

  test '#new requires edit?' do
    sign_in_as :user
    get new_deed_link_url(@deed)
    assert_redirected_to deed_url(@deed)
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#new allows editing own content' do
    user = sign_in_as :user
    deed = create(:deed, user: user)
    get new_deed_link_url(deed)
    assert_response :success
  end

  test '#new should return form' do
    sign_in_as :admin
    get new_deed_link_url(@deed)
    assert_response :success
    assert_select "form[action=\"#{deed_links_path(@deed)}\"]#new_link" do
      assert_select 'input[type=text]#link_text'
      assert_select 'input[type=url]#link_url'
      assert_select 'input[type=submit][value="Add link"]'
    end
  end

  test '#create requires auth' do
    post deed_links_url(@deed)
    assert_redirected_to new_sessions_url
    assert_equal 'You must be signed in to do that', flash[:warning]
  end

  test '#create requires edit?' do
    sign_in_as :user
    post deed_links_url(@deed)
    assert_redirected_to deed_url(@deed)
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#create allows user to add link to their own deed' do
    user = sign_in_as :user
    text = Faker::Lorem.word
    url = Faker::Internet.url
    deed = create(:deed, user: user)

    assert_difference 'user.links.count', 1 do
      assert_difference 'deed.links.count', 1 do
        post deed_links_url(deed), params: { link: { text: text, url: url } }
      end
    end

    link = deed.links.last
    assert_redirected_to deed_path(deed)
    assert_equal 'Link was successfully created.', flash[:notice]
    assert_equal text, link.text
    assert_equal url, link.url
  end

  test '#create allows admin to add link to any deed' do
    sign_in_as :admin
    text = Faker::Lorem.word
    url = Faker::Internet.url

    assert_difference '@deed.links.count', 1 do
      post deed_links_url(@deed), params: { link: { text: text, url: url } }
    end

    assert_redirected_to deed_path(@deed)
    assert_equal 'Link was successfully created.', flash[:notice]
  end

  test '#create shows model errors' do
    sign_in_as :admin

    assert_no_difference 'Link.count' do
      post deed_links_url(@deed), params: { link: { foo: 'bar' } }
    end
    assert_select '.card-error' do
      assert_select 'li', "Url can't be blank"
      assert_select 'li', "Text can't be blank"
      assert_select 'li', 'Url must be a valid URL'
      assert_select 'li', 3
    end
  end
end
