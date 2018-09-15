# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test '#create requires a token' do
    post subscriptions_url
    assert_response :forbidden
  end

  test '#create adds a subscription' do
    token = Faker::Internet.password(40, 60)
    stub_topic_info token, []
    assert_difference 'Subscription.count', 1 do
      post subscriptions_url params: { subscription: { token: token } }
    end
    assert_response :success
    subscription = Subscription.first
    assert_equal token, subscription.token
    assert_equal subscription.to_json, @response.body
    assert_equal 0, subscription.topics.count
    assert_equal session[:subscription_id], subscription.id
  end

  test '#create adds a subscription to a user' do
    user = sign_in_as :user
    stub_topic_info GoogleHelper::GOOGLE_TOKEN, []
    assert_difference 'user.subscriptions.count', 1 do
      post subscriptions_url params: { subscription: { token: GoogleHelper::GOOGLE_TOKEN } }
    end
    assert_response :success
    assert_equal Subscription.first.user, user
  end

  test '#create finds an existing subscription' do
    subscription = create(:subscription)
    stub_topic_info subscription.token, []
    assert_no_difference 'Subscription.count' do
      post subscriptions_url params: { subscription: { token: subscription.token } }
    end
    assert_response :success
    db_subscription = Subscription.first
    assert_equal db_subscription.token, subscription.token
    assert_equal db_subscription.to_json, @response.body
  end

  test '#show returns nothing for not subscription' do
    get subscriptions_url
    assert_response :forbidden
    assert_equal '{}', @response.body
  end

  test '#show current subscription' do
    subscription = create_subscription
    get subscriptions_url
    assert_response :success
    assert_equal subscription.to_json, @response.body
  end

  test '#destroy for no subscription' do
    delete subscriptions_url
    assert_response :forbidden
    assert_equal '{}', @response.body
  end

  test '#destroy current subscription' do
    create_subscription
    assert_difference 'Subscription.count', -1 do
      delete subscriptions_url
    end
    assert_response :success
    assert_equal '{}', @response.body
  end

  test '#patch adds a topic' do
    existing_topic = Faker::Lorem.word
    new_topic = Faker::Lorem.word
    subscription = create_subscription [existing_topic]
    stub_add_topic subscription.token, new_topic
    assert_difference 'subscription.reload.topics.count', 1 do
      patch subscriptions_url params: { subscription: { changes: [{ topic: new_topic, change: :add }] } }
    end
    assert_response :success
    assert_equal [existing_topic, new_topic], subscription.topics
    assert_equal subscription.topics, JSON.parse(@response.body)['topics']
  end

  test '#patch removes a topic' do
    topics = [Faker::Lorem.word, Faker::Lorem.word]
    subscription = create_subscription topics
    stub_remove_topic subscription.token, topics.first
    assert_difference 'subscription.reload.topics.count', -1 do
      patch subscriptions_url params: { subscription: { changes: [{ topic: topics.first, change: :remove }] } }
    end
    assert_response :success
    assert_equal [topics.second], subscription.reload.topics
    assert_equal subscription.topics, JSON.parse(@response.body)['topics']
  end

  def create_subscription(topics = [])
    token = Faker::Internet.password(40, 60)
    stub_topic_info token, topics
    post subscriptions_url params: { subscription: { token: token } }
    Subscription.find_by(token: token)
  end
end
