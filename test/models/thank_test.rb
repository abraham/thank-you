require 'test_helper'

class ThankTest < ActiveSupport::TestCase
  test 'should not save without text' do
    thank = Thank.new
    assert_not thank.save
  end

  test 'should save with text' do
    thank = Thank.new(text: Faker::Hipster.sentence)
    assert thank.save
  end
end
