require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @thank = create(:thank, user: @user)
    @default_admin_twitter_ids = AppConfig.admin_twitter_ids
  end

  def teardown
    AppConfig.admin_twitter_ids = @default_admin_twitter_ids
  end

  test 'admin? works for admins' do
    AppConfig.admin_twitter_ids = [@user.twitter_id]
    assert @user.admin?
  end

  test 'admin? does not work for users' do
    assert !@user.admin?
  end

  test '#dittoed? with no dittos' do
    assert !@user.dittoed?(@thank)
  end

  test '#dittoed? with dittos' do
    create(:ditto, user: @user, thank: @thank)
    assert @user.dittoed?(@thank)
  end
end
