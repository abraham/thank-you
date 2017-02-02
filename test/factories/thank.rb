FactoryGirl.define do
  factory :thank do
    user_name = Faker::Internet.user_name

    text { "Thank you @#{user_name} for #{Faker::Hipster.sentence}" }
    # reply_to_tweet_id
    name user_name
    user
  end
end
