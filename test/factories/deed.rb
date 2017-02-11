FactoryGirl.define do
  factory :deed do
    user_name = Faker::Internet.user_name

    text { Faker::Hipster.sentence }
    name [user_name]
    user
  end
end
