require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test '#require_active_user' do
    user = sign_in_as :user
    deed = create(:deed)
    user.disabled!
    get deed_url(deed)
    assert_redirected_to root_url
    assert_nil session[:user_id]
    assert_equal 'Your account is not activated', flash[:warning]
  end
end
