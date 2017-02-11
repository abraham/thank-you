FactoryGirl.define do
  factory :thank do
    user_name = Faker::Internet.user_name

    text { "Thank you @#{user_name} for #{Faker::Hipster.sentence}" }
    data { Faker::Twitter.status }
    user
    deed

    before(:create) do |thank|
      unless thank.tweet
        thank.build_tweet(attributes_for(:tweet))
        thank.tweet.user = thank.user
        thank.tweet.tweetable = thank
      end
    end

    after(:build) do |thank|
      unless thank.tweet
        build(:tweet, tweetable: thank)
        thank.build_tweet(attributes_for(:tweet))
        thank.tweet.user = thank.user
        thank.tweet.tweetable = thank
      end
    end
  end
end
