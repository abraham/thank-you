FactoryBot.define do
  factory :thank do
    screen_name = Faker::Twitter.screen_name
    data { Faker::Twitter.status }
    twitter_id { data[:id] }
    text { "Thank you @#{screen_name} for #{Faker::Hipster.word}" }
    user
    deed
  end
end
