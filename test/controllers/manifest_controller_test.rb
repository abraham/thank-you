# frozen_string_literal: true

require 'test_helper'

class ManifestControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get manifest_url(format: :json)
    assert_response :success
    assert JSON.parse(@response.body)
  end

  test 'should have image path' do
    get manifest_url(format: :json)
    json_response = JSON.parse(@response.body)
    image_url = 'http://www.example.com/assets/heart-6415107d2ffd301149ac39cda4a933feec08d2888b2b9350a9013836a6f66476.png'
    assert_equal image_url, json_response['icons'].first['src']
  end
end
