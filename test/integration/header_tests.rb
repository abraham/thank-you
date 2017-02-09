require 'test_helper'

class HeaderTest < ActionDispatch::IntegrationTest
  test 'sign in link rendered' do
    get root_url
    assert_select 'header' do
      assert_select "a[href=\"#{new_sessions_path}\"]", 'Sign in with Twitter'
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
      assert_select 'div#welcome', "Hi @#{user.screen_name}"
    end
  end

  test 'user has sign out form' do
    sign_in_as :user
    get root_url
    assert_select 'header' do
      assert_select "a[href=\"#{new_sessions_path}\"]", 0
      assert_select "form[action=\"#{sessions_path}\"]" do
        assert_select 'input[type=submit][value="Sign out"]'
      end
    end
  end

  test 'user has suggest deed link' do
    sign_in_as :user
    get root_url
    assert_select 'header' do
      assert_select "a[href=\"#{new_deed_path}\"]", 0
      assert_select 'a[href="https://goo.gl/forms/D8N4bQsz3gl7kbKo2"]', 'Suggest Thank You'
    end
  end

  test 'admin has create deed link' do
    sign_in_as :admin
    get root_url
    assert_select 'header' do
      assert_select "a[href=\"#{new_deed_path}\"]", 'Create deed'
      assert_select 'a[href="https://goo.gl/forms/D8N4bQsz3gl7kbKo2"]', 0
    end
  end
end
