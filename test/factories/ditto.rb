FactoryGirl.define do
  factory :ditto do
    user_name = Faker::Internet.user_name

    text { "Thank you @#{user_name} for #{Faker::Hipster.sentence}" }
    tweet_id { Faker::Number.number(10) }
    data { Faker::Twitter.status }
    user
    thank
  end
end
