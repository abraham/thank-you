FactoryGirl.define do
  factory :thank do
    user_name = Faker::Internet.user_name

    text { "Thank you @#{user_name} for #{Faker::Hipster.sentence}" }
    user
    deed
  end
end
