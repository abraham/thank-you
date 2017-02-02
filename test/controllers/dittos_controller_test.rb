require 'test_helper'

class DittosControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    post dittos_create_url
    assert_response :success
  end

end
