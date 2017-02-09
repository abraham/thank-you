require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  test 'url has a protocol' do
    deed = create(:deed)
    user = create(:user)
    link = Link.new(text: Faker::Lorem.word, url: 'example.com', user: user, deed: deed)
    assert_not link.valid?
  end
end
