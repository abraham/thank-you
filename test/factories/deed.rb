FactoryGirl.define do
  factory :deed do
    text { Faker::Hipster.sentence }
    names { [Faker::Internet.user_name(nil, ['_'])] }
    user

    trait :with_tweet do
      data { Faker::Twitter.status }
      twitter_id { data[:id] }
      names { [data[:user][:screen_name]] }
    end
  end
end
