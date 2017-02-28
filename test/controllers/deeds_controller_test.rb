require 'test_helper'

class DeedsControllerTest < ActionDispatch::IntegrationTest
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

  test '#index should get published deeds' do
    deeds = [create(:deed), create(:deed, :draft), create(:deed)]
    get root_path
    assert_response :success
    assert_select '.content' do
      assert_select '.mdc-card', 2
      assert_select 'h2 a', 2
      assert_select "h2 a[href=\"#{deed_path(deeds.first)}\"]", deeds.first.display_text
      assert_select "h2 a[href=\"#{deed_path(deeds.second)}\"]", 0
      assert_select "h2 a[href=\"#{deed_path(deeds.third)}\"]", deeds.third.display_text
    end
  end

  test '#drafts requires admin' do
    [:user, :editor, :moderator].each do |role|
      sign_in_as role
      get drafts_deeds_path
      assert_redirected_to root_url
      assert_equal 'You do not have permission to do that', flash[:warning]
    end
  end

  test '#drafts should get draft deeds' do
    deeds = [create(:deed, :draft), create(:deed), create(:deed, :draft)]
    sign_in_as :admin
    get drafts_deeds_path
    assert_response :success
    assert_select '.content' do
      assert_select 'h2 a', 2
      assert_select "h2 a[href=\"#{deed_path(deeds.first)}\"]", deeds.first.display_text
      assert_select "h2 a[href=\"#{deed_path(deeds.second)}\"]", 0
      assert_select "h2 a[href=\"#{deed_path(deeds.third)}\"]", deeds.third.display_text
    end
  end

  test '#index should show if thanked text' do
    user = sign_in_as :user
    deeds = [create(:deed), create(:deed), create(:deed)]
    thank = user.thanks.new(deed: deeds[1], text: deeds[1].text, url: deed_url(deeds[1]))
    status = "#{deeds[1].text} #{deed_url(deeds[1])}"
    stub_statuses_update(Faker::Twitter.status, status, in_reply_to_status_id: nil)
    thank.tweet
    thank.save
    get root_path
    assert_response :success
    assert_select "a[href=\"#{new_deed_thank_path(deeds[0])}\"]", "Thank @#{deeds[0].names.first}"
    assert_select "a[href=\"#{deed_path(deeds[1])}\"]", 'Already thanked'
    assert_select "a[href=\"#{new_deed_thank_path(deeds[2])}\"]", "Thank @#{deeds[2].names.first}"
  end

  test '#show renders deed' do
    deed = create(:deed)
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      assert_select 'h1', deed.display_text
      assert_select 'h1', 1
      assert_select 'p', 'Citations:'
      assert_select 'p', "Added by @#{deed.user.screen_name}"
    end
  end

  test '#show does not render draft deeds' do
    deed = create(:deed, :draft)
    get deed_path(deed)
    assert_response :not_found
    assert_select 'p', '404 Not found'
  end

  test '#show admin can see draft deeds' do
    sign_in_as :admin
    deed = create(:deed, :draft)
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      assert_select 'h1', deed.display_text
    end
  end

  test '#show draft deeds have publish button' do
    user = sign_in_as :user
    deed = create(:deed, :draft, user: user)
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      assert_select 'h1', deed.display_text
      assert_select 'h3', 'Deed preview'
      assert_select "form.deed_publish[action=\"#{deed_publish_path(deed)}\"]" do
        assert_select 'input[type=submit][value=Publish]', 1
        assert_select 'input', 1
      end
    end
  end

  test '#show user can see their own draft deeds' do
    user = sign_in_as :user
    deed = create(:deed, :draft, user: user)
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      assert_select 'h1', deed.display_text
    end
  end

  test '#show user can not see someone elses draft deeds' do
    sign_in_as :user
    deed = create(:deed, :draft)
    get deed_path(deed)
    assert_response :not_found
    assert_select 'p', '404 Not found'
  end

  test '#show renders not found for bad ID' do
    get deed_path(id: 'foo')
    assert_response :not_found
    assert_select 'p', '404 Not found'
  end

  test '#new requires authentication' do
    get new_deed_path
    assert_redirected_to new_sessions_url
  end

  test '#new redirects users with error' do
    sign_in_as :user
    get new_deed_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#new renders for editors and up' do
    [:editor, :moderator, :admin].each do |role|
      user = sign_in_as role
      get new_deed_path
      assert_response :success
      assert role.to_s, user.role
    end
  end

  test '#new should return form' do
    sign_in_as :admin
    get new_deed_path
    assert_select "form[action=\"#{deeds_path}\"]#new_deed" do
      assert_select 'input[type=text]#deed_names_', 4
      assert_select 'button.add-name', 'Add name'
      assert_select 'textarea#deed_text'
      assert_select 'input[type=text]#deed_twitter_id'
      assert_select 'input[type=submit][value="Preview"]'
      assert_select 'input', 7
      assert_select 'label', 6
    end
  end

  test '#create requires authentication' do
    post deeds_path
    assert_redirected_to new_sessions_url
  end

  test '#create redirects users with error' do
    sign_in_as :user
    post deeds_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#create renders for editors and up' do
    [:editor, :moderator, :admin].each do |role|
      user = sign_in_as role
      post deeds_path params: { deed: { text: 'foo' } }
      assert_response :success
      assert role.to_s, user.role
    end
  end

  test '#edit should not allow editing published deeds' do
    deed = create(:deed)
    sign_in_as :admin
    get edit_deed_url(deed)
    assert_redirected_to deed_path(deed)
    assert_equal "You can't edit published deeds", flash[:notice]
  end

  test '#edit should not allow users to edit other peoples deeds' do
    deed = create(:deed, :draft)
    sign_in_as :user
    get edit_deed_url(deed)
    assert_redirected_to deed_path(deed)
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#edit should allow editing own deeds' do
    user = sign_in_as :user
    deed = create(:deed, :draft, user: user)
    get edit_deed_url(deed)
    assert_response :success
  end

  test '#edit should return form' do
    deed = create(:deed, :draft)
    sign_in_as :admin
    get edit_deed_url(deed)
    assert_response :success
    assert_select "form[action=\"#{deed_path(deed)}\"]#edit_deed_#{deed.id}" do
      assert_select 'input[type=hidden][value=patch]'
      assert_select 'input[type=text]#deed_names_', 4
      assert_select 'button.add-name', 'Add name'
      assert_select 'textarea#deed_text'
      assert_select 'input[type=text]#deed_twitter_id'
      assert_select 'input[type=submit][value="Preview"]'
      assert_select 'input', 8
      assert_select 'label', 6
    end
  end

  test '#edit should hide names without values' do
    deed = create(:deed, :draft, names: ['one', 'two', 'three'])
    sign_in_as :admin
    get edit_deed_url(deed)
    assert_response :success
    assert_select "form[action=\"#{deed_path(deed)}\"]#edit_deed_#{deed.id}" do
      assert_select 'input[type=text]#deed_names_', 4
      assert_select 'input[type=text][value=one]#deed_names_', 1
      assert_select 'input[type=text][value=two]#deed_names_', 1
      assert_select 'input[type=text][value=three]#deed_names_', 1
      assert_select 'section.name.hidden', 1
      assert_select 'label[for=deed_names].mdc-textfield__label--float-above', 3
    end
  end

  test '#update allows admins to update Deeds' do
    sign_in_as :admin
    deed = create(:deed, :draft)
    text = deed.text + ' updated'
    names = deed.names << 'updated'
    assert_no_difference 'Deed.count' do
      patch deed_path(deed), params: { deed: { text: text, names: names } }
    end
    assert_redirected_to deed_path(deed)
    deed.reload
    assert deed.draft?
    assert_equal text, deed.text
    assert_equal names, deed.names
    assert_equal 'Deed updated successfully.', flash[:notice]
  end

  test '#update allows users to update thier own Deeds' do
    user = sign_in_as :user
    deed = create(:deed, :draft, user: user)
    text = deed.text + ' updated'
    names = deed.names << 'updated'
    assert_no_difference 'Deed.count' do
      patch deed_path(deed), params: { deed: { text: text, names: names } }
    end
    assert_redirected_to deed_path(deed)
    deed.reload
    assert deed.draft?
    assert_equal text, deed.text
    assert_equal names, deed.names
    assert_equal 'Deed updated successfully.', flash[:notice]
  end

  test '#update does not allow users to update others Deeds' do
    sign_in_as :user
    deed = create(:deed, :draft)
    text = deed.text
    names = deed.names
    assert_no_difference 'Deed.count' do
      patch deed_path(deed), params: { deed: { text: text + ' updated', names: names.dup.push('updated') } }
    end
    assert_redirected_to deed_path(deed)
    deed.reload
    assert deed.draft?
    assert_equal text, deed.text
    assert_equal names, deed.names
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#update allows changing tweet on draft Deed' do
    sign_in_as :admin
    deed = create(:deed, :draft, :with_tweet)
    status = Faker::Twitter.status
    stub_statuses_show status
    twitter_id = deed.twitter_id
    assert twitter_id
    assert deed.data
    assert_no_difference 'Deed.count' do
      patch deed_path(deed), params: { deed: { twitter_id: status[:id] } }
    end
    assert_redirected_to deed_path(deed)
    deed.reload
    assert_equal deed.twitter_id, status[:id].to_s
    assert_not_equal deed.twitter_id, twitter_id
    assert_equal deed.twitter_id, deed.tweet.id.to_s
    assert_equal 'Deed updated successfully.', flash[:notice]
  end

  test '#publish requires authentication' do
    deed = create(:deed)
    post deed_publish_path(deed)
    assert_redirected_to new_sessions_url
  end

  test '#publish makes draft deeds go live' do
    sign_in_as :admin
    deed = create(:deed, :draft)
    assert deed.draft?
    assert_no_difference 'Deed.count' do
      post deed_publish_path(deed)
    end
    assert_redirected_to deed_path(deed)
    deed.reload
    assert deed.published?
    assert_equal 'Deed published.', flash[:notice]
  end

  test '#create allows admins to create Deeds' do
    sign_in_as :admin
    text = Faker::Lorem.sentence
    names = [Faker::Twitter.screen_name]
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deed: { text: text, names: names, twitter_id: '' } }
    end
    deed = Deed.last
    assert_redirected_to deed_path(deed)
    assert deed.draft?
    assert_equal text, deed.text
    assert_equal names, deed.names
    assert_equal 'Deed created successfully.', flash[:notice]
  end

  test '#create allows admins to create Deeds with a Tweet' do
    sign_in_as :admin
    status = Faker::Twitter.status
    text = Faker::Lorem.sentence
    stub_statuses_show status
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deed: { text: text, names: [status[:user][:screen_name]], twitter_id: status[:id] } }
    end
    deed = Deed.last
    assert_redirected_to deed_path(deed)
    assert deed.draft?
    assert_equal status[:id].to_s, deed.twitter_id
    assert_equal status[:id], deed.data['id']
    assert_equal 'Deed created successfully.', flash[:notice]
  end

  test '#create allows admins to create Deeds with a Tweet URL instead of an ID' do
    sign_in_as :admin
    status = Faker::Twitter.status
    text = Faker::Lorem.sentence
    stub_statuses_show status
    assert_difference 'Deed.count', 1 do
      url = "https://twitter.com/#{status[:user][:screen_name]}/status/#{status[:id]}"
      post deeds_path, params: { deed: { text: text, names: [status[:user][:screen_name]], twitter_id: url } }
    end
    deed = Deed.last
    assert_redirected_to deed_path(deed)
    assert_equal status[:id].to_s, deed.twitter_id
    assert_equal status[:id], deed.data['id']
    assert_equal 'Deed created successfully.', flash[:notice]
  end

  test '#create allows admins to create Deeds with multiple names' do
    sign_in_as :admin
    text = Faker::Lorem.sentence
    names = [
      Faker::Twitter.screen_name,
      Faker::Twitter.screen_name,
      Faker::Twitter.screen_name
    ]
    assert_difference 'Deed.count', 1 do
      post deeds_path, params: { deed: { text: text, names: names } }
    end
    deed = Deed.last
    assert_redirected_to deed_path(deed)
    assert_equal text, deed.text
    assert_equal names, deed.names
    assert_equal 'Deed created successfully.', flash[:notice]
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

  test '#show has add link for own content' do
    user = sign_in_as :user
    deed = create(:deed, user: user)
    get deed_path(deed)
    assert_select '.links' do
      assert_select "a[href=\"#{new_deed_link_path(deed)}\"]", 'Add link'
    end
  end

  test '#show does not have add link for others content' do
    sign_in_as :user
    deed = create(:deed)
    get deed_path(deed)
    assert_select '.links' do
      assert_select "a[href=\"#{new_deed_link_path(deed)}\"]", 0
    end
  end

  test '#show has add link for admins' do
    sign_in_as :admin
    deed = create(:deed)
    get deed_path(deed)
    assert_select '.links' do
      assert_select "a[href=\"#{new_deed_link_path(deed)}\"]", 'Add link'
    end
  end

  test '#show has Twitter citation' do
    deed = create(:deed, :with_tweet)
    get deed_path(deed)
    assert_select '.links' do
      assert_select "a[href=\"#{deed.tweet.url}\"]", 'Twitter'
    end
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
      assert_select 'input[type=text]#deed_names_', 4
      assert_select 'input[value=one]#deed_names_', 1
      assert_select 'input[value=two]#deed_names_', 1
      assert_select 'input[value=three]#deed_names_', 1
      assert_select 'textarea#deed_text'
      assert_select 'input[type=submit][value="Preview"]'
    end
    assert_select '.card-error' do
      assert_select 'li', "Text can't be blank"
      assert_select 'li', 1
    end
  end

  test '#create shows Twitter errors' do
    sign_in_as :admin
    text = Faker::Lorem.sentence
    names = [Faker::Twitter.screen_name]
    stub_status_not_found
    assert_no_difference 'Deed.count' do
      post deeds_path, params: { deed: { text: text, names: names, twitter_id: '123' } }
    end
    assert_select "form[action=\"#{deeds_path}\"]#new_deed" do
      assert_select 'input[type=text]#deed_names_', 4
      assert_select 'textarea#deed_text'
      assert_select 'input[value="123"]#deed_twitter_id'
      assert_select 'input[type=submit][value="Preview"]'
    end
    assert_select '.card-error' do
      assert_select 'li', 'Twitter error: No status found with that ID.'
      assert_select 'li', "Data can't be blank"
      assert_select 'li', 2
    end
  end
end
