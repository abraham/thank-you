FactoryBot.define do
  factory :user do
    status :active
    role :user
    data { Faker::Twitter.user(include_email: true) }
    twitter_id { data[:id].to_s }
    screen_name { data[:screen_name] }
    name { data[:name] }
    email { data[:email] }
    avatar_url { data[:profile_image_url_https] }
    access_token { "#{twitter_id}-#{Faker::Internet.password(30, 40)}" }
    access_token_secret { Faker::Internet.password(40, 50) }
    default_avatar { data[:default_profile_image] }

    trait :user do; end

    trait :editor do
      role :editor
    end

    trait :moderator do
      role :moderator
    end

    trait :admin do
      role :admin
    end

    trait :active do; end

    trait :disabled do
      status :disabled
    end

    trait :expired do
      status :expired
    end
  end
end
