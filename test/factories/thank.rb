FactoryGirl.define do
  factory :thank do
    user_name = Faker::Internet.user_name.sub('.', '_')
    data { Faker::Twitter.status }
    twitter_id { data[:id] }
    text { "Thank you @#{user_name} for #{Faker::Hipster.sentence}" }
    user
    deed
  end
end
