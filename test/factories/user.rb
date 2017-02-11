FactoryGirl.define do
  factory :user do
    status :active
    data do
      Faker::Twitter.user.merge(email: Faker::Internet.safe_email,
                                screen_name: Faker::Internet.user_name.sub('.', '_'))
    end
    twitter_id { data[:id].to_s }
    screen_name { data[:screen_name] }
    name { data[:name] }
    email { data[:email] }
    avatar_url { data[:profile_image_url_https] }
    access_token { "#{twitter_id}-#{Faker::Internet.password(30, 40)}" }
    access_token_secret { Faker::Internet.password(40, 50) }
    default_avatar { data[:default_profile_image] }
  end
end
