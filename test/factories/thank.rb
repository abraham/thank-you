FactoryGirl.define do
  factory :thank do
    user_name = Faker::Internet.user_name

    text { "Thank you @#{user_name} for #{Faker::Hipster.sentence}" }
    tweet_id { Faker::Number.number(10) }
    data { Faker::Twitter.status }
    user
    deed
  end
end
