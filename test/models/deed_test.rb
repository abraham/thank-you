require 'test_helper'

class DeedTest < ActiveSupport::TestCase
  test 'should not save without text' do
    deed = Deed.new
    assert_not deed.save
  end

  test 'should save with text' do
    deed = Deed.new(text: Faker::Hipster.sentence,
                      name: Faker::Internet.user_name,
                      user: create(:user))
    assert deed.save
  end
end
