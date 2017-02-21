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
                    names: [Faker::Internet.user_name(nil, ['_'])],
                    user: create(:user))
    assert deed.save
  end

  test 'should save with four names' do
    names = [
      Faker::Internet.user_name(nil, ['_']),
      Faker::Internet.user_name(nil, ['_']),
      Faker::Internet.user_name(nil, ['_']),
      Faker::Internet.user_name(nil, ['_'])
    ]
    deed = Deed.new(text: Faker::Hipster.sentence,
                    names: names,
                    user: create(:user))
    assert deed.save
  end

  test 'should not save with more than four names' do
    names = [
      Faker::Internet.user_name(nil, ['_']),
      Faker::Internet.user_name(nil, ['_']),
      Faker::Internet.user_name(nil, ['_']),
      Faker::Internet.user_name(nil, ['_']),
      Faker::Internet.user_name(nil, ['_'])
    ]
    deed = Deed.new(text: Faker::Hipster.sentence,
                    names: names,
                    user: create(:user))
    assert_not deed.save
    assert_equal ['Names has too many values'], deed.errors.full_messages
  end

  test '#etl! should do nothing sometimes' do
    deed = build(:deed)
    assert_nil deed.twitter_id
    assert_nil deed.data
    assert_nil deed.etl!
    deed.data = Faker::Twitter.status
    assert_nil deed.etl!
  end

  test '#etl! should get status from Twitter' do
    status = Faker::Twitter.status
    stub = stub_statuses_show status
    deed = build(:deed)
    deed.twitter_id = status[:id]
    assert_difference 'Deed.count', 1 do
      assert deed.save
    end
    assert_equal deed.data['id'], status[:id]
    remove_request_stub stub
  end

  test '#etl! should throw an error if tweet not found' do
    status = Faker::Twitter.status
    stub = stub_status_not_found
    deed = build(:deed)
    deed.twitter_id = status[:id]
    assert_difference 'Deed.count', 0 do
      assert_not deed.save
    end
    assert_not deed.valid?
    assert_equal ['Twitter error: No status found with that ID.', "Data can't be blank"], deed.errors.full_messages
    remove_request_stub stub
  end

  test '#clean_names should reject empty values' do
    deed = Deed.new(names: ['', nil])
    deed.valid?
    assert_equal [], deed.names
  end

  test '#clean_twitter_id should reject empty values' do
    deed = Deed.new(twitter_id: '')
    deed.valid?
    assert_nil deed.twitter_id
  end

  test '#display_text' do
    deed = create(:deed)
    assert_equal "Thank You @#{deed.names.first} for #{deed.text}", deed.display_text
    deed.names << Faker::Internet.user_name(nil, ['_'])
    deed.names << Faker::Internet.user_name(nil, ['_'])
    text = "Thank You @#{deed.names.first}, @#{deed.names.second}, and @#{deed.names.third} for #{deed.text}"
    assert_equal text, deed.display_text
  end

  test '#display_names' do
    deed = create(:deed)
    assert_equal "@#{deed.names.first}", deed.display_names
    deed.names << Faker::Internet.user_name(nil, ['_'])
    deed.names << Faker::Internet.user_name(nil, ['_'])
    assert_equal "@#{deed.names.first}, @#{deed.names.second}, and @#{deed.names.third}", deed.display_names
  end
end
