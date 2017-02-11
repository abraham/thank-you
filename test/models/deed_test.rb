require 'test_helper'

class DeedTest < ActiveSupport::TestCase
  test 'should not save without text' do
    expected_errors = ['User must exist', "User can't be blank", "Names can't be blank", "Text can't be blank"]
    deed = Deed.new
    assert_not deed.save
    assert_equal expected_errors, deed.errors.full_messages
  end

  test 'should save with text' do
    deed = Deed.new(text: Faker::Hipster.sentence,
                    names: [Faker::Internet.user_name],
                    user: create(:user))
    assert deed.save
  end

  test 'should save with three names' do
    deed = Deed.new(text: Faker::Hipster.sentence,
                    names: [Faker::Internet.user_name, Faker::Internet.user_name, Faker::Internet.user_name],
                    user: create(:user))
    assert deed.save
  end

  test 'should not save with more than three names' do
    names = [Faker::Internet.user_name, Faker::Internet.user_name, Faker::Internet.user_name, Faker::Internet.user_name]
    deed = Deed.new(text: Faker::Hipster.sentence,
                    names: names,
                    user: create(:user))
    assert_not deed.save
    assert_equal ['Names has too many values'], deed.errors.full_messages
  end
end
