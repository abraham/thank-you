# frozen_string_literal: true

require 'test_helper'

class AboutControllerTest < ActionDispatch::IntegrationTest
  test 'should get terms' do
    get about_terms_url
    assert_response :success
  end

  test 'should get privacy' do
    get about_privacy_url
    assert_response :success
  end
end
