require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @default_admin_twitter_ids = AppConfig.admin_twitter_ids
  end

  def teardown
    AppConfig.admin_twitter_ids = @default_admin_twitter_ids
  end

  test 'admin? works for admins' do
    user = create(:user)
    AppConfig.admin_twitter_ids = [user.twitter_id]
    assert user.admin?
  end

  test 'admin? does not work for users' do
    user = create(:user)
    assert !user.admin?
  end
end
