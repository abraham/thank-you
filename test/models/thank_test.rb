require 'test_helper'

class ThankTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test '#save associated with deed and user' do
    deed = create(:deed)
    thank = build(:thank, user: @user, deed: deed)
    assert_difference 'Thank.count', 1 do
      assert_difference 'deed.thanks.count', 1 do
        assert_difference '@user.thanks.count', 1 do
          assert thank.save
        end
      end
    end
  end

  test '#tweet posts to Twitter and saves' do
    status = Faker::Twitter.status
    deed = create(:deed, text: status[:text])
    status[:text] = "#{deed.text} https://example.com"
    stub_statuses_update(status, status[:text], in_reply_to_status_id: nil)
    thank = @user.thanks.new(deed: deed, text: deed.text, url: 'https://example.com')
    assert thank.tweet
    assert_equal thank.twitter_id, status[:id].to_s
    assert thank.data.present?
    assert_equal thank.data['text'], status[:text]
  end

  test '#tweet posts to Twitter as a reply' do
    status = Faker::Twitter.status
    user = create(:user)
    deed = create(:deed, :with_tweet, text: status[:text])
    stub_statuses_update(status, "#{status[:text]} https://example.com", in_reply_to_status_id: deed.twitter_id)
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
  end

  test '#tweet text gets URL appended' do
    status = Faker::Twitter.status
    text = Faker::Lorem.sentence
    url = 'https://example.com'
    user = create(:user)
    deed = create(:deed, text: text)
    status[:text] = "#{text} #{url}"
    stub_statuses_update(status, status[:text], in_reply_to_status_id: nil)
    thank = user.thanks.new(deed: deed, text: text, url: url)
    assert thank.tweet
    assert thank.save
    assert_equal thank.text, text
    assert_equal thank.data['text'], "#{text} #{url}"
  end

  test '#save can not create duplicates' do
    status_one = Faker::Twitter.status
    status_two = Faker::Twitter.status
    user = create(:user)
    deed = create(:deed, text: status_one[:text])
    stub_statuses_update(status_one, "#{status_one[:text]} https://example.com", in_reply_to_status_id: nil)
    thank = user.thanks.new(deed: deed, text: status_one[:text], url: 'https://example.com')
    assert_difference 'Thank.count', 1 do
      assert thank.tweet
      assert thank.save
    end
    thank_two = user.thanks.new(deed: deed, text: status_two[:text], url: 'https://example.com')
    assert_not thank_two.valid?
    assert_equal ['Deed has already been thanked', "Twitter can't be blank"], thank_two.errors.full_messages
  end

  test 'validation' do
    thank = build(:thank)
    assert thank.valid?
    thank.data = nil
    assert_not thank.valid?
    assert_equal ["Data can't be blank"], thank.errors.full_messages
    thank.twitter_id = nil
    assert_not thank.valid?
    assert_equal ["Twitter can't be blank", "Url can't be blank"], thank.errors.full_messages
    thank.text = nil
    assert_not thank.valid?
    invalid_errors = [
      'Twitter is not a valid tweet',
      "Text can't be blank",
      "Twitter can't be blank",
      "Url can't be blank"
    ]
    assert_equal invalid_errors, thank.errors.full_messages
  end

  test '#tweetable? requires values' do
    thank = Thank.new
    assert_not thank.send(:tweetable?)
    invalid_errors = [
      'Deed must exist',
      "Deed can't be blank",
      'User must exist',
      "User can't be blank",
      'Twitter is not a valid tweet',
      "Text can't be blank",
      "Twitter can't be blank",
      "Url can't be blank"
    ]
    assert_equal invalid_errors, thank.errors.full_messages
    assert_not thank.valid?
  end

  test '#tweetable? knows when it is ready to tweet' do
    thank = Thank.new(user: create(:user),
                      deed: create(:deed),
                      text: Faker::Lorem.sentence,
                      url: 'https://example.com')
    assert thank.send(:tweetable?)
    assert_not thank.valid?
  end

  test '#tweetable? is false if already tweeted' do
    thank = Thank.new(user: create(:user),
                      deed: create(:deed),
                      text: Faker::Lorem.sentence,
                      twitter_id: 123,
                      data: { foo: :bar })
    assert_not thank.send(:tweetable?)
    assert thank.valid?
    assert_equal [], thank.errors.full_messages
  end
end
