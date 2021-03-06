# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @deed = create(:deed, user: @user)
  end

  test '#admin? works for admins' do
    user = create(:user, :admin)
    assert user.admin?
    assert_equal user.role, 'admin'
  end

  test '#admin? does not work for users' do
    assert_not @user.admin?
    assert_equal @user.role, 'user'
  end

  test '#client is Twitter API with user credentials' do
    assert_instance_of Twitter::REST::Client, @user.client
    assert_equal 'fake_key', @user.client.consumer_key
    assert_equal 'fake_secret', @user.client.consumer_secret
    assert_equal @user.access_token, @user.client.access_token
    assert_equal @user.access_token_secret, @user.client.access_token_secret
  end

  test '#edit? as admin' do
    user = create(:user, :admin)
    deed = create(:deed)
    assert user.edit?(deed)
    deed = create(:deed, user: user)
    assert user.edit?(deed)
  end

  test '#edit? as user' do
    deed = create(:deed)
    assert_not @user.edit?(deed)
    deed = create(:deed, user: @user)
    assert @user.edit?(deed)
  end

  test '#etl sets user attributes' do
    twitter_user = Faker::Twitter.user(include_email: true)
    stub_verify_credentials(twitter_user)
    user = User.new(twitter_id: twitter_user[:id],
                    access_token: TwitterHelper::TWITTER_TOKEN,
                    access_token_secret: TwitterHelper::TWITTER_SECRET)
    assert user.etl
    assert user.save
    assert_equal twitter_user[:email], user.email
    assert_equal twitter_user[:id].to_s, user.twitter_id
    assert_equal twitter_user[:name], user.name
    assert_equal twitter_user[:profile_image_url_https], user.avatar_url
    assert_equal twitter_user[:screen_name], user.screen_name
    assert_equal twitter_user[:default_profile_image], user.default_avatar?
    assert user.data.present?
    assert_equal twitter_user[:email], user.data['email']
    assert_equal twitter_user[:id], user.data['id']
    assert_equal twitter_user[:name], user.data['name']
    assert_equal twitter_user[:profile_image_url_https], user.data['profile_image_url_https']
    assert_equal twitter_user[:screen_name], user.data['screen_name']
    assert_equal twitter_user[:default_profile_image], user.default_avatar?
  end

  test '#etl updates existing user' do
    twitter_user = Faker::Twitter.user(include_email: true)
    stub_verify_credentials(twitter_user)
    user = create(:user, twitter_id: twitter_user[:id],
                         access_token: TwitterHelper::TWITTER_TOKEN,
                         access_token_secret: TwitterHelper::TWITTER_SECRET)
    assert_not_equal twitter_user[:email], user.email
    assert_not_equal twitter_user[:name], user.name
    assert_not_equal twitter_user[:profile_image_url_https], user.avatar_url
    assert_not_equal twitter_user[:screen_name], user.screen_name
    assert user.etl
    assert user.save
    assert_equal twitter_user[:email], user.email
    assert_equal twitter_user[:id].to_s, user.twitter_id
    assert_equal twitter_user[:name], user.name
    assert_equal twitter_user[:profile_image_url_https], user.avatar_url
    assert_equal twitter_user[:screen_name], user.screen_name
    assert_equal twitter_user[:default_profile_image], user.default_avatar?
  end

  test '#etled? knows if Twitter data is present' do
    user = build(:user)
    assert user.etled?
    user.data = nil
    assert_not user.etled?
    user.data = {}
    assert_not user.etled?
  end

  test '#thanked? if a user has thanked a deed' do
    assert_not @user.thanked?(@deed)
    create(:thank, user: @user, deed: @deed)
    assert @user.thanked?(@deed)
  end

  test '#tweet posts text to Twitter' do
    status = Faker::Twitter.status
    stub_statuses_update(status, status[:text], in_reply_to_status_id: nil)
    tweet = @user.tweet(status[:text], nil)
    assert_equal status, tweet.to_hash
  end

  test '#tweet posts text to Twitter as a reply' do
    status = Faker::Twitter.status
    in_reply_to_status_id = Faker::Number.number(10)
    stub_statuses_update(status, status[:text], in_reply_to_status_id: in_reply_to_status_id)
    tweet = @user.tweet(status[:text], in_reply_to_status_id)
    assert_equal status, tweet.to_hash
  end

  test '#tweet fails when disabled' do
    AppConfig.posting_to_twitter_enabled = false
    assert_raise RuntimeError, 'Posting to Twitter disabled' do
      @user.tweet(Faker::Lorem.sentence, nil)
    end
    AppConfig.posting_to_twitter_enabled = true
  end

  test '#tweet raises unauthorized exception' do
    stub_unauthorized
    assert_raise Twitter::Error::Unauthorized, 'Could not authenticate you' do
      @user.tweet(Faker::Lorem.sentence, nil)
    end
  end

  test '#tweet raises forbidden exception for status over 140 characters' do
    stub_over_140
    assert_raise Twitter::Error::Forbidden, 'Status is over 140 characters' do
      @user.tweet(Faker::Lorem.sentence * 3, nil)
    end
  end

  test '#tweet raises rate limit exception' do
    stub_rate_limit
    assert_raise Twitter::Error::TooManyRequests, 'Rate limit exceeded' do
      @user.tweet(Faker::Lorem.sentence, nil)
    end
  end

  test '#from_access_token fetches user details from Twitter' do
    twitter_user = Faker::Twitter.user(include_email: true)
    stub_verify_credentials(twitter_user)
    assert_not User.find_by(twitter_id: twitter_user[:id_str])
    assert_difference 'User.count', 1 do
      User.from_access_token(twitter_user[:id], TwitterHelper::TWITTER_TOKEN, TwitterHelper::TWITTER_SECRET)
    end
    assert User.find_by(twitter_id: twitter_user[:id_str])
  end

  test '#from_access_token fetches user details from Twitter for exising user' do
    stub_verify_credentials(@user.data)
    assert_no_difference 'User.count' do
      User.from_access_token(@user.data['id'], TwitterHelper::TWITTER_TOKEN, TwitterHelper::TWITTER_SECRET)
    end
    assert_equal User.last.twitter_id, @user.data['id_str']
  end

  test '#active?' do
    user = create(:user)
    assert user.active?
    assert_equal user.status, 'active'
  end

  test '#disabled?' do
    user = create(:user, :disabled)
    assert user.disabled?
    assert_equal user.status, 'disabled'
  end

  test '#expired?' do
    user = create(:user, :expired)
    assert user.expired?
    assert_equal user.status, 'expired'
  end

  test '#default_avatar?' do
    user = create(:user, default_avatar: false)
    assert_not user.default_avatar?
    user.default_avatar = true
    assert user.default_avatar?
  end
end
