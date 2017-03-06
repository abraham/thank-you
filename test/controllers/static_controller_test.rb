require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  test 'should get firebase-messaging-sw' do
    get firebase_messaging_sw_url, xhr: true
    assert_response :success
  end
end
