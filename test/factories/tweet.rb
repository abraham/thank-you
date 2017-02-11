FactoryGirl.define do
  factory :tweet do
    data { Faker::Twitter.status }
    text { data[:text] }
    add_attribute(:twitter_id) { data[:id] }
    user
    association :tweetable, factory: :thank
  end
end
