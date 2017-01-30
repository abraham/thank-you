require 'test_helper'

class DittosControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get dittos_create_url
    assert_response :success
  end

end
