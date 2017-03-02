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

  test 'GET /deeds/popular' do
    assert_routing({ path: 'deeds/popular', method: :get }, controller: 'deeds', action: 'popular')
  end

  test 'GET /deeds/drafts' do
    assert_routing({ path: 'deeds/drafts', method: :get }, controller: 'deeds', action: 'drafts')
  end

  test 'GET /deeds/start' do
    assert_routing({ path: 'deeds/start', method: :get }, controller: 'deeds', action: 'start')
  end

  test 'POST /deeds/etl' do
    assert_routing({ path: 'deeds/etl', method: :post }, controller: 'deeds', action: 'etl')
  end

  test 'POST /deeds/:id/publish' do
    assert_routing({ path: 'deeds/123/publish', method: :post }, controller: 'deeds', action: 'publish', deed_id: '123')
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

  test '#index should get most recent deeds' do
    deed = create(:deed, created_at: 1.day.ago)
    create_list(:deed, 10)
    get root_path
    assert_response :success
    assert_select '.content' do
      assert_select '.mdc-card', 10
      assert_select 'h2 a', 10
      assert_select "h2 a[href=\"#{deed_path(deed)}\"]", 0
    end
  end

  test '#index should show no results text' do
    get root_path
    assert_response :success
    assert_select '.content' do
      assert_select 'div', 'No content found.'
    end
  end

  test '#index should show older button' do
    deeds = create_list(:deed, 10)
    get root_path
    assert_response :success
    assert_select '.content' do
      assert_select '.pagination a', count: 0, text: 'Newer'
      assert_select '.pagination a[rel=prev]', href: root_path(before: deeds.last.created_at), text: 'Older'
    end
  end

  test '#index should show page 1 newer and older button' do
    newer_deeds = create_list(:deed, 10)
    older_deeds = create_list(:deed, 10, created_at: 1.day.ago)
    get root_path(before: newer_deeds.last.created_at)
    assert_response :success
    assert_select '.content' do
      # assert_select '.pagination a[rel=next]', href: root_path, text: 'Newer'
      assert_select '.pagination a[rel=prev]', href: root_path(before: older_deeds.last.created_at), text: 'Older'
    end
  end

  test '#index should show newer button' do
    newer_deeds = create_list(:deed, 10)
    middle_deeds = create_list(:deed, 10, created_at: 1.day.ago)
    create_list(:deed, 5, created_at: 2.days.ago)
    get root_path(before: middle_deeds.last.created_at)
    assert_response :success
    assert_select '.content' do
      # assert_select '.pagination a[rel=next]', href: root_path(before: newer_deeds.last.created_at), text: 'Newer'
      assert_select '.pagination a', count: 0, text: 'Older'
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

  test '#index should have sort button' do
    get root_path
    assert_response :success
    assert_select '.content' do
      assert_select 'button', 'sort Sort by'
      assert_select "a[href=\"#{root_path}\"].mdc-button--accent", 'Most recent'
      assert_select "a[href=\"#{popular_deeds_path}\"]:not(.mdc-button--accent)", 'Most popular'
    end
  end

  test '#popular should get popular deeds' do
    deeds = [create(:deed, :popular), create(:deed, :popular)]
    create_list(:deed, 25)
    get popular_deeds_path
    assert_response :success
    assert_select '.content' do
      assert_select '.mdc-card', 10
      assert_select 'h2 a', 10
      assert_select "h2 a[href=\"#{deed_path(deeds.first)}\"]", deeds.first.display_text
      assert_select "h2 a[href=\"#{deed_path(deeds.second)}\"]", deeds.second.display_text
    end
  end

  test '#popular should have sort button' do
    get popular_deeds_path
    assert_response :success
    assert_select '.content' do
      assert_select 'button', 'sort Sort by'
      assert_select "a[href=\"#{root_path}\"]:not(.mdc-button--accent)", 'Most recent'
      assert_select "a[href=\"#{popular_deeds_path}\"].mdc-button--accent", 'Most popular'
    end
  end

  test '#popular should show no results text' do
    get popular_deeds_path
    assert_response :success
    assert_select '.content' do
      assert_select 'div', 'No content found.'
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

  test '#drafts should show no results text' do
    sign_in_as :admin
    get drafts_deeds_path
    assert_response :success
    assert_select '.content' do
      assert_select 'div', 'No content found.'
    end
  end

  test '#show renders deed' do
    deed = create(:deed)
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      assert_select 'h1', deed.display_text
      assert_select 'h1', 1
      assert_select 'section', 'Citations:'
      assert_select 'section', "Added by @#{deed.user.screen_name}"
      assert_select "a[href=\"#{new_deed_thank_path(deed)}\"]", "Thank @#{deed.names.first}"
      assert_select 'section', "You can be the first to thank #{deed.display_names}"
    end
  end

  test '#show renders thanks' do
    deed = create(:deed)
    thanks = [
      create(:thank, deed: deed),
      create(:thank, deed: deed),
      create(:thank, deed: deed)
    ]
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      thanks.each do |thank|
        a = "a[href=\"https://twitter.com/#{thank.user.screen_name}/status/#{thank.twitter_id}\"]"
        img = "img[src=\"#{thank.user.avatar_url}\"]"
        assert_select "#{a} #{img}", 1
      end
      assert_select 'span', 'Thanked by'
    end
  end

  test '#show if user thanked' do
    user = sign_in_as :user
    deed = create(:deed)
    thank = create(:thank, user: user, deed: deed)
    create(:thank, deed: deed)
    get deed_path(deed)
    assert_response :success
    assert_select 'main' do
      assert_select 'p', "You already thanked #{deed.display_names} 👍"
      assert_select 'span', 'Thanked by you and 1 other'
      a = "a[href=\"https://twitter.com/#{user.screen_name}/status/#{thank.twitter_id}\"]"
      img = "img[src=\"#{user.avatar_url}\"]"
      assert_select "#{a} #{img}", 1
    end
  end

  test '#show renders social links' do
    deed = create(:deed)
    get deed_path(deed)
    assert_select 'main' do
      assert_select 'a', href: "https://plus.google.com/share?url=#{deed_url(deed)}", text: 'Google+'
      assert_select 'a', href: "https://www.facebook.com/sharer/sharer.php?u=#{deed_url(deed)}", text: 'Facebook'
      assert_select 'a', href: "https://www.linkedin.com/shareArticle?url=#{deed_url(deed)}", text: 'LinkedIn'
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

  test '#start requires authentication' do
    get start_deeds_path
    assert_redirected_to new_sessions_url
  end

  test '#start redirects users with error' do
    sign_in_as :user
    get start_deeds_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#start renders for editors and up' do
    [:editor, :moderator, :admin].each do |role|
      user = sign_in_as role
      get start_deeds_path
      assert_response :success
      assert role.to_s, user.role
    end
  end

  test '#start should return form' do
    sign_in_as :admin
    get start_deeds_path
    assert_select "form[action=\"#{etl_deeds_path}\"]" do
      assert_select 'input[type=text]#deed_twitter_id', 1
      assert_select "a[href=\"#{new_deed_path}\"]", 'Advanced'
      assert_select 'input[type=submit][value="Preview"]'
      assert_select 'input', 3
      assert_select 'label', 1
    end
  end

  test '#etl requires authentication' do
    post etl_deeds_path
    assert_redirected_to new_sessions_url
  end

  test '#etl redirects users with error' do
    sign_in_as :user
    post etl_deeds_path
    assert_redirected_to root_path
    assert_equal 'You do not have permission to do that', flash[:warning]
  end

  test '#etl renders for editors and up' do
    [:editor, :moderator, :admin].each do |role|
      user = sign_in_as role
      status = Faker::Twitter.status
      stub_statuses_show status
      post etl_deeds_path params: { deed: { twitter_id: status[:id] } }
      deed = Deed.find_by_twitter_id(status[:id])
      assert_redirected_to edit_deed_url(deed)
      assert role.to_s, user.role
    end
  end

  test '#etl creates a deed from ID' do
    user = sign_in_as :admin
    status = Faker::Twitter.status
    stub_statuses_show status
    assert_difference 'user.deeds.count', 1 do
      post etl_deeds_path params: { deed: { twitter_id: status[:id] } }
    end
    deed = Deed.last
    assert_redirected_to edit_deed_url(deed)
    assert_equal status[:id].to_s, deed.twitter_id
    assert_equal [status[:user][:screen_name]], deed.names
    assert_equal status[:text], deed.text
  end

  test '#etl creates a deed from URL' do
    user = sign_in_as :admin
    status = Faker::Twitter.status
    stub_statuses_show status
    twitter_id = "https://twitter.com/#{status[:user][:screen_name]}/status/#{status[:id]}"
    assert_difference 'user.deeds.count', 1 do
      post etl_deeds_path params: { deed: { twitter_id: twitter_id } }
    end
    deed = Deed.last
    assert_redirected_to edit_deed_url(deed)
    assert_equal status[:id].to_s, deed.twitter_id
    assert_equal [status[:user][:screen_name]], deed.names
    assert_equal status[:text], deed.text
  end

  test '#etl shows tweet not found error' do
    sign_in_as :admin
    stub_status_not_found
    assert_no_difference 'Deed.count' do
      post etl_deeds_path params: { deed: { twitter_id: 'https://twitter.com/jack/status/404' } }
    end
    assert_select '.card-error' do
      assert_select 'li', 'Twitter error: No status found with that ID.'
      assert_select 'li', 1
    end
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
      assert_select "a[href=\"#{root_path}\"]", 'Cancel'
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
      assert_select "a[href=\"#{deed_path(deed)}\"]", 'Cancel'
      assert_select 'input[type=submit][value="Preview"]'
      assert_select 'input', 8
      assert_select 'label', 6
    end
  end

  test '#edit should hide names without values' do
    deed = create(:deed, :draft, names: ['one', 'two'])
    sign_in_as :admin
    get edit_deed_url(deed)
    assert_response :success
    assert_select "form[action=\"#{deed_path(deed)}\"]#edit_deed_#{deed.id}" do
      assert_select 'input[type=text]#deed_names_', 4
      assert_select 'input[type=text][value=one]#deed_names_', 1
      assert_select 'input[type=text][value=two]#deed_names_', 1
      assert_select 'input[type=text][value]#deed_names_', 2
      assert_select 'section.name.hidden', 1
      assert_select 'label[for=deed_names].mdc-textfield__label--float-above', 2
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
    assert_select 'h1', "#{deed.display_names} is evil alert(666)"
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
