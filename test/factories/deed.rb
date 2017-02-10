FactoryGirl.define do
  factory :deed do
    user_name = Faker::Internet.user_name

    text { "Thank you @#{user_name} for #{Faker::Hipster.sentence}" }
    name user_name
    user
  end
end
