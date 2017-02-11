require 'test_helper'

class ThankTest < ActiveSupport::TestCase
  test 'text length conforms to Twitter spec' do
    thank = build(:thank)
    assert thank.valid?
    thank.text = 'n' * 200
    assert !thank.valid?
    assert_equal 'Text is not a valid tweet', thank.errors.full_messages.first
    thank.text = 'https://example.com ' * 6
    assert !thank.valid?
    assert_equal 'Text is not a valid tweet', thank.errors.full_messages.first
    thank.text = "Thank You @twitter for #{'n' * 93} https://example.com"
    assert thank.valid?
    thank.text = "Thank You @twitter for #{'n' * 94} https://example.com"
    assert !thank.valid?
    assert_equal 'Text is not a valid tweet', thank.errors.full_messages.first
  end

  test '#new works with factory girl' do
    thank = build(:thank)
    assert thank.valid?
    assert thank.tweet.valid?
    assert thank.new_record?
    assert thank.tweet.new_record?
  end

  test '#create works with factory girl' do
    thank = create(:thank)
    assert thank
    assert thank.tweet
    assert_not thank.new_record?
    assert_not thank.tweet.new_record?
  end
end
