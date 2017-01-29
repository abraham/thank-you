require 'test_helper'

class StatusesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get statuses_new_url
    assert_response :success
  end

end
