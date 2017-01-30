require 'test_helper'

TWEET_DATA = '{"coordinates":null,"favorited":false,"truncated":false,"created_at":"Wed Jun 06 20:07:10 +0000 2012","id_str":"210462857140252672","entities":{"urls":[{"expanded_url":"/terms/display-guidelines","url":"https://t.co/Ed4omjYs","indices":[76,97],"display_url":"dev.twitter.com/terms/display-\u2026"}],"hashtags":[{"text":"Twitterbird","indices":[19,31]}],"user_mentions":[]},"in_reply_to_user_id_str":null,"contributors":[14927800],"text":"Along with our new #Twitterbird, we\'ve also updated our Display Guidelines: https://t.co/Ed4omjYs  ^JC","retweet_count":66,"in_reply_to_status_id_str":null,"id":210462857140252672,"geo":null,"retweeted":true,"possibly_sensitive":false,"in_reply_to_user_id":null,"place":null,"user":{"profile_sidebar_fill_color":"DDEEF6","profile_sidebar_border_color":"C0DEED","profile_background_tile":false,"name":"Twitter API","profile_image_url":"http://a0.twimg.com/profile_images/2284174872/7df3h38zabcvjylnyfe3_normal.png","created_at":"Wed May 23 06:01:13 +0000 2007","location":"San Francisco, CA","follow_request_sent":false,"profile_link_color":"0084B4","is_translator":false,"id_str":"6253282","entities":{"url":{"urls":[{"expanded_url":null,"url":"","indices":[0,22]}]},"description":{"urls":[]}},"default_profile":true,"contributors_enabled":true,"favourites_count":24,"url":"","profile_image_url_https":"https://si0.twimg.com/profile_images/2284174872/7df3h38zabcvjylnyfe3_normal.png","utc_offset":-28800,"id":6253282,"profile_use_background_image":true,"listed_count":10774,"profile_text_color":"333333","lang":"en","followers_count":1212963,"protected":false,"notifications":null,"profile_background_image_url_https":"https://si0.twimg.com/images/themes/theme1/bg.png","profile_background_color":"C0DEED","verified":true,"geo_enabled":true,"time_zone":"Pacific Time (US & Canada)","description":"The Real Twitter API. I tweet about API changes, service issues and happily answer questions about Twitter and our API. Don\'t get an answer? It\'s on my website.","default_profile_image":false,"profile_background_image_url":"http://a0.twimg.com/images/themes/theme1/bg.png","statuses_count":3333,"friends_count":31,"following":true,"show_all_inline_media":false,"screen_name":"twitterapi"},"in_reply_to_screen_name":null,"source":"web","in_reply_to_status_id":null}'
TWEET_ID = '210462857140252672'
TWEET_TEXT = "Along with our new #Twitterbird, we've also updated our Display Guidelines: https://t.co/Ed4omjYs  ^JC"

class TweetTest < ActiveSupport::TestCase
  def setup
    stub_request(:post, 'https://api.twitter.com/oauth2/token')
      .with(body: 'grant_type=client_credentials',
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Basic ZmFrZV9rZXk6ZmFrZV9zZWNyZXQ=',
              'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
              'User-Agent' => 'TwitterRubyGem/6.1.0'
            })
      .to_return(status: 200,
                 body: '{"token_type":"bearer","access_token":"fake_access_token"}',
                 headers: {})
    stub_request(:get, "https://api.twitter.com/1.1/statuses/show/#{TWEET_ID}.json")
      .with(headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization' => 'Bearer fake_access_token',
              'User-Agent' => 'TwitterRubyGem/6.1.0'
            })
      .to_return(status: 200, body: TWEET_DATA, headers: {})
  end

  test 'should not save without needed fields' do
    tweet = Tweet.new
    assert_not tweet.save
  end

  test 'parses Tweet IDs from Twitter URLs' do
    assert Tweet.id_from_url('https://twitter.com/user/statues/123'), '123'
    assert Tweet.id_from_url('twitter.com/user/statues/123'), '123'
    assert Tweet.id_from_url('123'), '123'
  end

  test 'gets tweets from twitter' do
    tweet = Tweet.get_tweet(TWEET_ID)
    assert_instance_of Twitter::Tweet, tweet
    assert_equal tweet.text, TWEET_TEXT
    assert_equal tweet.id.to_s, TWEET_ID
  end

  test 'creates Tweets from tweet IDs' do
    tweet = Tweet.from_id(TWEET_ID)
    assert_instance_of Tweet, tweet
    assert_equal tweet.text, TWEET_TEXT
    assert_equal tweet.id, TWEET_ID
  end

  test 'tweets can be saved' do
    assert_difference 'Tweet.count', 1 do
      tweet = Tweet.from_id(TWEET_ID)
      assert tweet.save
    end
  end
end
