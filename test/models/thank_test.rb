require 'test_helper'

class ThankTest < ActiveSupport::TestCase
  test 'should not save without text' do
    thank = Thank.new
    assert_not thank.save
  end

  test 'should save with text' do
    thank = Thank.new(text: Faker::Hipster.sentence,
                      name: Faker::Internet.user_name,
                      user: create(:user))
    assert thank.save
  end
end
