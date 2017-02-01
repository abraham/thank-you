require 'test_helper'

class LinksControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get links_new_url
    assert_response :success
  end

  test "should get create" do
    get links_create_url
    assert_response :success
  end

end
