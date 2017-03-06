require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test '#create requires a token' do
    post subscriptions_url
    assert_response :forbidden
  end

  test '#create' do
    stub_topic_subscription :deeds
    post subscriptions_url params: { subscription: { topic: :deeds, token: GoogleHelper::GOOGLE_TOKEN } }
    assert_response :success
  end

  test '#destroy requires a token' do
    delete subscriptions_url
    assert_response :forbidden
  end

  test '#show requires a token' do
    get subscriptions_url
    assert_response :forbidden
  end

  test '#create makes request to Google' do
    stub_topic_subscription :deeds
    post subscriptions_url params: { subscription: { topic: :deeds, token: GoogleHelper::GOOGLE_TOKEN } }
    assert_response :success
    assert_equal @response.body, { added: :deeds }.to_json
  end
end
