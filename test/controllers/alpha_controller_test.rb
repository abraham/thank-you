require 'test_helper'

class AlphaControllerTest < ActionDispatch::IntegrationTest
  test "should get join" do
    get alpha_join_url
    assert_response :success
  end

end
