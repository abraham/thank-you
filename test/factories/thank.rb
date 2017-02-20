FactoryGirl.define do
  factory :thank do
    user_name = Faker::Internet.user_name(nil, ['_'])
    data { Faker::Twitter.status }
    twitter_id { data[:id] }
    text { "Thank you @#{user_name} for #{Faker::Hipster.word}" }
    user
    deed
  end
end
