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
      assert_select "h2 a[href=\"#{deed_path(deed)}\"]", deed.display_text
    end
    assert_select 'h2 a', 3
  end

  test '#show renders deed' do
    deed = create(:deed)
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      assert_select 'h1', deed.display_text
      assert_select 'p', 'Citations:'
    end
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

  test '#new should return form' do
    sign_in_as :admin
    get new_deed_path
    assert_response :success
    assert_select "form[action=\"#{deeds_path}\"]#new_deed" do
      assert_select 'input[type=text]#deed_names_', 3
      assert_select 'textarea#deed_text'
      assert_select 'input[type=text]#deed_twitter_id'
      assert_select 'input[type=submit][value="Create deed"]'
    end
  end

  test '#create allows admins to create Deeds' do
    sign_in_as :admin
    text = Faker::Lorem.sentence
    names = [Faker::Internet.user_name]
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deed: { text: text, names: names, twitter_id: '' } }
    end
    deed = Deed.last
    assert_redirected_to deed_path(deed)
    assert_equal text, deed.text
    assert_equal names, deed.names
    assert_equal 'Thank You created successfully.', flash[:notice]
  end

  test '#create allows admins to create Deeds with a Tweet' do
    sign_in_as :admin
    status = Faker::Twitter.status
    text = Faker::Lorem.sentence
    names = [Faker::Internet.user_name]
    stub = stub_statuses_show status
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deed: { text: text, names: names, twitter_id: status[:id] } }
    end
    deed = Deed.last
    assert_redirected_to deed_path(deed)
    assert_equal status[:id].to_s, deed.twitter_id
    assert_equal status[:id], deed.data['id']
    assert_equal 'Thank You created successfully.', flash[:notice]
    remove_request_stub stub
  end

  test '#create allows admins to create Deeds with multiple names' do
    sign_in_as :admin
    text = Faker::Lorem.sentence
    names = [Faker::Internet.user_name, Faker::Internet.user_name, Faker::Internet.user_name]
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deed: { text: text, names: names } }
    end
    deed = Deed.last
    assert_redirected_to deed_path(deed)
    assert_equal text, deed.text
    assert_equal names, deed.names
    assert_equal 'Thank You created successfully.', flash[:notice]
  end

  test '#create shows model errors' do
    sign_in_as :admin

    assert_no_difference 'Deed.count' do
      post deeds_path, params: { deed: { foo: 'bar' } }
    end
    assert_select '.card-error' do
      assert_select 'li', "Names can't be blank"
      assert_select 'li', "Text can't be blank"
      assert_select 'li', 2
    end
  end

  test '#show links tweet text' do
    deed = create(:deed, text: 'cool stuff https://example.com/cool/stuff')
    get deed_path(deed)
    assert_response :success
    assert_select 'h1', deed.display_text
    assert_select 'h1 a', 2
    assert_select 'h1 a', deed.names.first
    assert_select 'h1 a', 'https://example.com/cool/stuff'
  end

  test '#show escapes evil deed text' do
    deed = create(:deed, text: '<a href="javascript:alert(666)">evil</a> <script>alert(666)</script>')
    get deed_path(deed)
    assert_response :success
    assert_select 'h1', "Thank You #{deed.display_names} for evil alert(666)"
    assert_select 'h1 a[href]', 1
    assert_select "h1 a[href=\"https://twitter.com/#{deed.names.first}\"]", 1
    assert_select 'h1 script', 0
  end

  test '#create renders names on error' do
    sign_in_as :admin
    names = [:one, :two, :three]
    assert_no_difference 'Deed.count' do
      post deeds_path, params: { deed: { names: names } }
    end
    assert_select "form[action=\"#{deeds_path}\"]#new_deed" do
      assert_select 'input[type=text]#deed_names_', 3
      assert_select 'input[value=one]#deed_names_', 1
      assert_select 'input[value=two]#deed_names_', 1
      assert_select 'input[value=three]#deed_names_', 1
      assert_select 'textarea#deed_text'
      assert_select 'input[type=submit][value="Create deed"]'
    end
    assert_select '.card-error' do
      assert_select 'li', "Text can't be blank"
      assert_select 'li', 1
    end
  end

  test '#create shows Twitter errors' do
    sign_in_as :admin
    text = Faker::Lorem.sentence
    names = [Faker::Internet.user_name]
    stub = stub_status_not_found
    assert_no_difference 'Deed.count' do
      post deeds_path, params: { deed: { text: text, names: names, twitter_id: '123' } }
    end
    assert_select "form[action=\"#{deeds_path}\"]#new_deed" do
      assert_select 'input[type=text]#deed_names_', 3
      assert_select 'textarea#deed_text'
      assert_select 'input[value="123"]#deed_twitter_id'
      assert_select 'input[type=submit][value="Create deed"]'
    end
    assert_select '.card-error' do
      assert_select 'li', 'Twitter error: No status found with that ID.'
      assert_select 'li', "Data can't be blank"
      assert_select 'li', 2
    end
    remove_request_stub stub
  end
end
