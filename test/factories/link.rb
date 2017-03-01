FactoryGirl.define do
  factory :link do
    text { Faker::Lorem.word }
    url { Faker::Internet.url('example.com') }
    user
    deed
  end
end
