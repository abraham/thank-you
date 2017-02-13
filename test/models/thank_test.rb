require 'test_helper'

class ThankTest < ActiveSupport::TestCase
  test 'text length conforms to Twitter spec' do
    thank = build(:thank)
    thank.url = 'https://example.com'
    assert thank.valid?
    thank.text = 'n' * 200
    assert_not thank.valid?
    assert_equal 'Text is not a valid tweet', thank.errors.full_messages.first
    thank.text = 'https://example.com ' * 6
    assert_not thank.valid?
    assert_equal 'Text is not a valid tweet', thank.errors.full_messages.first
    thank.text = "Thank You @twitter for #{'n' * 93}"
    assert thank.valid?
    thank.text = "Thank You @twitter for #{'n' * 94}"
    assert_not thank.valid?
    assert_equal 'Text is not a valid tweet', thank.errors.full_messages.first
  end

  test '#tweet posts to Twitter' do
    status = Faker::Twitter.status
    user = create(:user)
    deed = create(:deed, text: status[:text])
    stub = stub_statuses_update(status, "#{status[:text]} https://example.com", in_reply_to_status_id: nil)
    thank = user.thanks.new(deed: deed, text: deed.text, url: 'https://example.com')
    assert_difference 'Thank.count', 1 do
      assert_difference 'deed.thanks.count', 1 do
        assert_difference 'user.thanks.count', 1 do
          assert thank.tweet
          assert thank.save
        end
      end
    end
    assert_not thank.new_record?
    assert_equal thank.twitter_id, status[:id].to_s
    assert_equal thank.text, status[:text]
    remove_request_stub stub
  end

  test '#tweet text gets URL appended' do
    status = Faker::Twitter.status
    text = Faker::Lorem.sentence
    url = 'https://example.com'
    user = create(:user)
    deed = create(:deed, text: text)
    status[:text] = "#{text} #{url}"
    stub = stub_statuses_update(status, status[:text], in_reply_to_status_id: nil)
    thank = user.thanks.new(deed: deed, text: text, url: url)
    assert thank.tweet
    assert thank.save
    assert_equal thank.text, text
    assert_equal thank.data['text'], "#{text} #{url}"
    remove_request_stub stub
  end

  test '#save can not create duplicates' do
    status_one = Faker::Twitter.status
    status_two = Faker::Twitter.status
    user = create(:user)
    deed = create(:deed, text: status_one[:text])
    stub = stub_statuses_update(status_one, "#{status_one[:text]} https://example.com", in_reply_to_status_id: nil)
    thank = user.thanks.new(deed: deed, text: status_one[:text], url: 'https://example.com')
    assert_difference 'Thank.count', 1 do
      assert thank.tweet
      assert thank.save
    end
    thank_two = user.thanks.new(deed: deed, text: status_two[:text], url: 'https://example.com')
    assert_not thank_two.valid?
    assert_equal ['Deed has already been thanked', "Twitter can't be blank"], thank_two.errors.full_messages
    remove_request_stub stub
  end
end
