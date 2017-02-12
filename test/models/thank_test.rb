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

  test '#tweet posts to Twitter' do
    status = Faker::Twitter.status
    user = create(:user)
    deed = create(:deed, text: status[:text])
    stub = stub_statuses_update(status, status[:text], in_reply_to_status_id: nil)
    thank = user.thanks.new(deed: deed, text: deed.text)
    assert_difference 'Thank.count', 1 do
      assert_difference 'deed.thanks.count', 1 do
        assert_difference 'user.thanks.count', 1 do
          assert thank.tweet
        end
      end
    end
    assert_not thank.new_record?
    assert_equal thank.twitter_id, status[:id].to_s
    assert_equal thank.text, status[:text]
    remove_request_stub stub
  end
end
