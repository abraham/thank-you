require 'test_helper'

class ThankTest < ActiveSupport::TestCase
  test 'text length conforms to Twitter spec' do
    deed = create(:deed)
    thank = deed.thanks.new(user: deed.user, text: 'Hello World')
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
end
