# frozen_string_literal: true

require 'test_helper'

class TweetTest < ActionDispatch::IntegrationTest
  test 'Deed#show should not include tweet card' do
    deed = create(:deed)
    get deed_url(deed)
    assert_response :success
    assert_select '.tweet', false
    assert_nil deed.twitter_id
    assert_nil deed.data
    assert_select 'p', count: 0, text: /in reply to.../
  end

  test 'Deed#show should include tweet card' do
    deed = create(:deed, :with_tweet)
    get deed_url(deed)
    assert_response :success
    assert deed.twitter_id
    assert deed.data
    assert_select 'section', /in reply to.../
    assert_select '.tweet', 1
    assert_select ".tweet-#{deed.twitter_id}" do
      assert_select '.mdc-card__media', 0
      assert_select 'style', 0
      assert_select 'div.mdc-card__horizontal-block' do
        assert_select "a[href=\"#{deed.tweet.user.uri}\"]" do
          assert_select "img[src=\"#{deed.tweet.user.profile_image_uri_https(:bigger)}\"].avatar", 1
        end
        assert_select 'section.mdc-card__primary' do
          assert_select "div.mdc-card__title a[href=\"#{deed.tweet.user.uri}\"]", deed.tweet.user.name
          assert_select "div.mdc-card__subtitle a[href=\"#{deed.tweet.user.uri}\"]", "@#{deed.tweet.user.screen_name}"
        end
      end
      assert_select 'section.mdc-card__supporting-text', deed.tweet.full_text
      assert_select 'section.mdc-card__supporting-text' do
        assert_select "a[href=\"#{deed.tweet.uri}\"]", deed.tweet.created_at.strftime('%l:%M %p - %e %b %Y')
      end
    end
  end

  test 'Deed#show should include tweet with media' do
    deed = create(:deed, :with_photo_tweet)
    get deed_url(deed)
    assert_response :success
    assert deed.twitter_id
    assert deed.data
    assert_select '.tweet', 1
    assert_select ".tweet-#{deed.twitter_id}" do
      assert_select '.mdc-card__media', 1
      assert_select 'style', /#{Regexp.escape(".tweet-#{deed.twitter_id} .mdc-card__media")}/
      assert_select 'style', /#{Regexp.escape('background-image: url("https://lorempixel.com/1064/600");')}/
      assert_select 'style', /background-size: cover;/
      assert_select 'style', /background-repeat: no-repeat;/
      assert_select 'style', /height: 300px;/
    end
  end

  test 'Thank#new should include tweet card' do
    sign_in_as :user
    deed = create(:deed, :with_tweet)
    get new_deed_thank_url(deed)
    assert_response :success
    assert_select '.tweet', 1
    assert_select ".tweet-#{deed.twitter_id}" do
      assert_select '.mdc-card__media', 0
      assert_select 'style', 0
      assert_select 'div.mdc-card__horizontal-block' do
        assert_select "a[href=\"#{deed.tweet.user.uri}\"]" do
          assert_select "img[src=\"#{deed.tweet.user.profile_image_uri_https(:bigger)}\"].avatar", 1
        end
        assert_select 'section.mdc-card__primary' do
          assert_select "div.mdc-card__title a[href=\"#{deed.tweet.user.uri}\"]", deed.tweet.user.name
          assert_select "div.mdc-card__subtitle a[href=\"#{deed.tweet.user.uri}\"]", "@#{deed.tweet.user.screen_name}"
        end
      end
      assert_select 'section.mdc-card__supporting-text', deed.tweet.full_text
      assert_select 'section.mdc-card__supporting-text' do
        assert_select "a[href=\"#{deed.tweet.uri}\"]", deed.tweet.created_at.strftime('%l:%M %p - %e %b %Y')
      end
    end
  end
end
