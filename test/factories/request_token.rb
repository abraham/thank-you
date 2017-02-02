FactoryGirl.define do
  factory :request_token do
    token { Faker::Internet.password(10, 20) }
    secret { Faker::Internet.password(30, 40) }
  end
end
