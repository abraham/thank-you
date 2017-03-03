require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test '#drafts requires signin' do
    user = create(:user)
    get user_drafts_url(user)
    assert_redirected_to new_sessions_path
    assert_equal 'You must be signed in to do that.', flash[:warning]
  end

  test '#drafts are only available to to current_use' do
    other_user = create(:user)
    user = sign_in_as :user
    get user_drafts_url(other_user)
    assert_not_equal user.id, other_user.id
    assert_redirected_to root_url
    assert_equal 'You do not have permission to do that.', flash[:warning]
  end

  test '#drafts should get drafts' do
    user = sign_in_as :editor
    get user_drafts_url(user)
    assert_response :success
  end

  test '#drafts should show no results text' do
    user = sign_in_as :editor
    get user_drafts_url(user)
    assert_response :success
    assert_select '.content' do
      assert_select 'div', 'No content found.'
    end
  end

  test '#drafts is not available to users' do
    user = sign_in_as :user
    get user_drafts_url(user)
    assert_redirected_to root_url
    assert_equal 'You do not have permission to do that.', flash[:warning]
  end

  test '#drafts requires admin' do
    [:editor, :moderator, :admin].each do |role|
      user = sign_in_as role
      get user_drafts_url(user)
      assert_response :success
      assert_equal role.to_s, user.role
    end
  end

  test '#drafts should get own draft deeds' do
    user = sign_in_as :editor
    deeds = [create(:deed, :draft, user: user), create(:deed, user: user), create(:deed, :draft)]
    get user_drafts_url(user)
    assert_response :success
    assert_select '.content' do
      assert_select 'h2 a', 1
      assert_select "h2 a[href=\"#{deed_path(deeds.first)}\"]", deeds.first.display_text
      assert_select "h2 a[href=\"#{deed_path(deeds.second)}\"]", 0
      assert_select "h2 a[href=\"#{deed_path(deeds.third)}\"]", 0
    end
  end
end
