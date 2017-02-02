require 'test_helper'

class AlphaControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect to root' do
    get alpha_join_url token: 'secure-token'
    assert_redirected_to root_url
    assert_equal @response.cookies['alpha_token'], 'secure-token'
  end

  test 'should get join' do
    get alpha_join_url token: 'nope'
    assert_redirected_to root_url
    assert @response.cookies['alpha_token'].nil?
  end
end
