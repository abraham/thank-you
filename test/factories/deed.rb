FactoryGirl.define do
  factory :deed do
    status :published
    text { Faker::Hipster.sentence }
    names { [Faker::Internet.user_name(nil, ['_'])] }
    user

    trait :with_tweet do
      data { Faker::Twitter.status }
      twitter_id { data[:id] }
      names { [data[:user][:screen_name]] }
    end

    trait :with_photo_tweet do
      data { Faker::Twitter.status(include_photo: true) }
      twitter_id { data[:id] }
      names { [data[:user][:screen_name]] }
    end
  end
end
