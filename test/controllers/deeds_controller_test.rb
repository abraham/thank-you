require 'test_helper'

class DeedsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @default_admin_twitter_ids = AppConfig.admin_twitter_ids
  end

  def teardown
    AppConfig.admin_twitter_ids = @default_admin_twitter_ids
  end

  test 'GET /' do
    assert_routing({ path: '/', method: :get }, controller: 'deeds', action: 'index')
  end

  test 'POST /deeds' do
    assert_routing({ path: 'deeds', method: :post }, controller: 'deeds', action: 'create')
  end

  test 'GET /deeds/new' do
    assert_routing({ path: 'deeds/new', method: :get }, controller: 'deeds', action: 'new')
  end

  test 'GET /deeds/:id' do
    assert_routing({ path: 'deeds/123', method: :get }, controller: 'deeds', action: 'show', id: '123')
  end

  test '#index redirects to root' do
    get deeds_path
    assert_redirected_to root_path
  end

  test '#root should get deeds' do
    deeds = [create(:deed), create(:deed), create(:deed)]
    get root_path
    assert_response :success
    deeds.each do |deed|
      assert_select 'strong', deed.text
    end
  end

  test '#show renders deed' do
    deed = create(:deed)
    get deed_path(deed)
    assert_response :success
    assert_select 'strong', deed.text
    assert_select 'p', 'Citations:'
  end

  test '#new requires authentication' do
    get new_deed_path
    assert_redirected_to new_sessions_url
  end

  test '#create requires authentication' do
    post deeds_path
    assert_redirected_to new_sessions_url
  end

  test '#new redirects users with error' do
    sign_in_as :user
    get new_deed_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#create redirects users with error' do
    sign_in_as :user
    post deeds_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#new is available to admins' do
    sign_in_as :admin
    get new_deed_path
    assert_response :success
  end

  test '#create allows admins to create Deeds' do
    sign_in_as :admin
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deeds: { text: Faker::Lorem.sentence(3), name: Faker::Internet.user_name } }
    end
    assert_redirected_to deed_path(Deed.last)
    assert_equal 'Thank You created successfully.', flash[:notice]
  end

  test '#create shows model errors' do
    sign_in_as :admin

    assert_difference 'Deed.count', 0 do
      post deeds_path, params: { deeds: { foo: 'bar' } }
    end
    assert_select '#form-error' do
      assert_select 'li', "Name can't be blank"
      assert_select 'li', "Text can't be blank"
    end
  end
end
