# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test '#require_active_user' do
    user = sign_in_as :user
    deed = create(:deed)
    user.disabled!
    get deed_url(deed)
    assert_redirected_to root_url
    assert_nil session[:user_id]
    assert_equal 'Your account is not activated.', flash[:warning]
  end

  test 'Firebase config is rendered' do
    get root_url
    assert_select 'head' do
      assert_select 'meta[name=firebase-api-key][content=AIzaSyD-bJd7gfkobCKrhclz-yyjA-Jva_Q0F2o]'
      assert_select 'meta[name=firebase-messaging-sender-id][content="133536989471"]'
    end
  end
end
