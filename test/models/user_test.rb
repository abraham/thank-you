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

  test 'tweet makes request to Twitter' do
    status = Faker::Twitter.status
    in_reply_to_status_id = Faker::Number.number(10)
    stub_statuses_update(status, in_reply_to_status_id)
    tweet = @user.tweet(status[:text], in_reply_to_status_id)
    assert_equal status, tweet.to_hash
  end

  def stub_statuses_update(status, in_reply_to_status_id)
    stub_request(:post, 'https://api.twitter.com/1.1/statuses/update.json')
      .with(body: { in_reply_to_status_id: in_reply_to_status_id, status: status[:text] })
      .to_return(status: 200, body: status.to_json)
  end
end
