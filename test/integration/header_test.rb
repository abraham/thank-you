require 'test_helper'

class HeaderTest < ActionDispatch::IntegrationTest
  test 'title is present' do
    get root_url
    assert_select 'header' do
      assert_select 'div.mdc-toolbar__title', 'Thank You'
    end
  end

  test 'sign in link rendered' do
    get root_url
    assert_select 'header' do
      assert_select "a[href=\"#{new_sessions_path}\"]", 'Sign in'
    end
  end

  test 'sign in link not rendered on new_sessions_path' do
    get new_sessions_url
    assert_select 'header' do
      assert_select "a[href=\"#{new_sessions_path}\"]", 0
    end
  end

  test 'user personalized welcome message' do
    user = sign_in_as :user
    get root_url
    assert_select 'header' do
      assert_select "img[src=\"#{user.avatar_url}\"].menu", 1
      assert_select 'div.mdc-simple-menu' do
        assert_select "a[href=\"https://twitter.com/#{user.screen_name}\"]", "Hi @#{user.screen_name}"
      end
    end
  end

  test 'user has sign out form' do
    sign_in_as :user
    get root_url
    assert_select 'header' do
      assert_select "a[href=\"#{new_sessions_path}\"]", 0
      assert_select 'div.mdc-simple-menu' do
        assert_select "form[action=\"#{sessions_path}\"]" do
          assert_select 'input[type=submit][value="Sign out"]'
        end
      end
    end
  end

  test 'user has suggest deed link' do
    user = sign_in_as :user
    get root_url
    assert_select 'header' do
      assert_select 'div.mdc-simple-menu' do
        assert_select 'a[href="https://goo.gl/forms/D8N4bQsz3gl7kbKo2"]', 'Suggest Thank You'
        assert_select "a[href=\"#{start_deeds_path}\"]", 0
        assert_select "a[href=\"#{drafts_deeds_path}\"]", 0
        assert_select "a[href=\"#{user_drafts_path(user)}\"]", 0
      end
    end
  end

  test 'editor and up has deed links' do
    [:editor, :moderator].each do |role|
      user = sign_in_as role
      get root_url
      assert role.to_s, user.role
      assert_select 'header' do
        assert_select 'div.mdc-simple-menu' do
          assert_select 'a[href="https://goo.gl/forms/D8N4bQsz3gl7kbKo2"]', 0
          assert_select "a[href=\"#{drafts_deeds_path}\"]", 0
          assert_select "a[href=\"#{start_deeds_path}\"]", 'Add deed'
          assert_select "a[href=\"#{user_drafts_path(user)}\"]", 'My drafts'
        end
      end
    end
  end

  test 'admin has draft deeds link' do
    user = sign_in_as :admin
    get root_url
    assert_select 'header' do
      assert_select 'div.mdc-simple-menu' do
        assert_select "a[href=\"#{start_deeds_path}\"]", 'Add deed'
        assert_select "a[href=\"#{user_drafts_path(user)}\"]", 'My drafts'
        assert_select "a[href=\"#{drafts_deeds_path}\"]", 'All drafts'
      end
    end
  end
end
