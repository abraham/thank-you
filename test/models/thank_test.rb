require 'test_helper'

class ThankTest < ActiveSupport::TestCase
  test 'should not save without text' do
    thank = Thank.new
    assert_not thank.save
  end
end
