require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @deed = create(:deed)
    @user = @deed.user
    @default_admin_twitter_ids = AppConfig.admin_twitter_ids
  end

  def teardown
    AppConfig.admin_twitter_ids = @default_admin_twitter_ids
  end

  test '#etl! sets user' do
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    stub = stub_verify_credentials(twitter_user)
    user = User.new(twitter_id: twitter_user[:id],
                    access_token: TwitterHelper::TWITTER_TOKEN,
                    access_token_secret: TwitterHelper::TWITTER_SECRET)
    user.etl!
    assert user.etled?
    assert user.save
    assert_equal twitter_user[:id].to_s, user.twitter_id
    assert_equal twitter_user[:email], user.email
    assert_equal twitter_user[:name], user.name
    assert_equal twitter_user[:screen_name], user.screen_name
    assert_equal twitter_user[:profile_image_url_https], user.avatar_url
    remove_request_stub stub
  end

  test '#etl! sets user.data' do
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    stub = stub_verify_credentials(twitter_user)
    user = User.new(twitter_id: twitter_user[:id],
                    access_token: TwitterHelper::TWITTER_TOKEN,
                    access_token_secret: TwitterHelper::TWITTER_SECRET)
    user.etl!
    assert user.etled?
    assert user.save
    assert_equal twitter_user[:id], user.data['id']
    assert_equal twitter_user[:email], user.data['email']
    assert_equal twitter_user[:name], user.data['name']
    assert_equal twitter_user[:screen_name], user.data['screen_name']
    assert_equal twitter_user[:profile_image_url_https], user.data['profile_image_url_https']
    remove_request_stub stub
  end

  test '#etl! updates existing user' do
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    stub = stub_verify_credentials(twitter_user)
    user = create(:user,
                  twitter_id: twitter_user[:id],
                  access_token: TwitterHelper::TWITTER_TOKEN,
                  access_token_secret: TwitterHelper::TWITTER_SECRET)
    user.etl!
    assert user.etled?
    assert user.save
    assert_equal twitter_user[:id].to_s, user.twitter_id
    assert_equal twitter_user[:email], user.email
    assert_equal twitter_user[:name], user.name
    assert_equal twitter_user[:screen_name], user.screen_name
    assert_equal twitter_user[:profile_image_url_https], user.avatar_url
    remove_request_stub stub
  end

  test '#admin? works for admins' do
    AppConfig.admin_twitter_ids = [@user.twitter_id]
    assert @user.admin?
  end

  test '#admin? does not work for users' do
    assert_not @user.admin?
  end

  test '#thanked? with no thanks' do
    assert_not @user.thanked?(@deed)
  end

  test '#thanked? with thanks' do
    create(:thank, user: @user, deed: @deed)
    assert @user.thanked?(@deed)
  end

  test '#tweet makes request to Twitter' do
    status = Faker::Twitter.status
    in_reply_to_status_id = Faker::Number.number(10)
    stub = stub_statuses_update(status, status[:text], in_reply_to_status_id: in_reply_to_status_id)
    tweet = @user.tweet(status[:text], in_reply_to_status_id)
    assert_equal status, tweet.to_hash
    remove_request_stub stub
  end

  test '#tweet fails when disabled' do
    AppConfig.posting_to_twitter_enabled = false
    assert_raise RuntimeError, 'Posting to Twitter disabled' do
      @user.tweet(Faker::Lorem.sentence(3), nil)
    end
    AppConfig.posting_to_twitter_enabled = true
  end

  test '#etled? knows if Twitter data is present' do
    user = build(:user)
    assert user.send(:etled?)
    user.data = nil
    assert_not user.send(:etled?)
    user.data = {}
    assert_not user.send(:etled?)
  end

  test '#from_access_token fetches user details from Twitter' do
    access_token = TwitterHelper::TWITTER_TOKEN
    access_token_secret = TwitterHelper::TWITTER_SECRET
    twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
    stub = stub_verify_credentials(twitter_user)
    assert_not User.find_by(twitter_id: twitter_user[:id_str])
    assert_difference 'User.count', 1 do
      User.from_access_token(twitter_user[:id], access_token, access_token_secret)
    end
    assert User.find_by(twitter_id: twitter_user[:id_str])
    remove_request_stub stub
  end

  test '#from_access_token fetches user details from Twitter for exising user' do
    access_token = TwitterHelper::TWITTER_TOKEN
    access_token_secret = TwitterHelper::TWITTER_SECRET
    stub = stub_verify_credentials(@user.data)
    assert_no_difference 'User.count' do
      User.from_access_token(@user.data['id'], access_token, access_token_secret)
    end
    assert_equal User.last.twitter_id, @user.data['id_str']
    remove_request_stub stub
  end

  test '#active?' do
    user = create(:user)
    assert user.active?
    assert_not user.disabled?
  end

  test '#disabled?' do
    user = create(:user, status: :disabled)
    assert_not user.active?
    assert user.disabled?
  end

  test '#expired?' do
    user = create(:user, status: :expired)
    assert_not user.active?
    assert user.expired?
  end

  test '#default_avatar?' do
    user = create(:user, default_avatar: false)
    assert_not user.default_avatar?
    user.default_avatar = true
    assert user.default_avatar?
  end
end
