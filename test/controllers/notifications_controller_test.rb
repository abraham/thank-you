# frozen_string_literal: true

require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get notifications_url
    assert_response :success
  end

  test 'all deeds switch is rendered' do
    get notifications_url
    assert_response :success
    assert_select '.notifications' do
      assert_select 'input[type=checkbox][id=deeds]'
      assert_select 'label[for=deeds]', 'Tell me about new Deeds'
    end
  end
end
