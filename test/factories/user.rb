FactoryGirl.define do
  factory :user do
    twitter_id = Faker::Number.between(1, 10)
    twitter_id twitter_id
    screen_name { Faker::Internet.user_name }
    name { Faker::Name.name }
    avatar_url { Faker::Avatar.image(twitter_id, '48x48') }
    data { { foo: :bar } }
    access_token { Faker::Internet.password(10, 20) }
    access_token_secret { Faker::Internet.password(20, 30) }
  end
end
