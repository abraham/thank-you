FactoryGirl.define do
  factory :user do
    data { Faker::Twitter.user.merge(email: Faker::Internet.safe_email) }
    twitter_id { data[:id].to_s }
    screen_name { data[:screen_name] }
    name { Faker::Name.name }
    email { data[:email] }
    avatar_url { data[:profile_image_url_https] }
    access_token { "#{twitter_id}-#{Faker::Internet.password(30, 40)}" }
    access_token_secret { Faker::Internet.password(40, 50) }
  end
end
