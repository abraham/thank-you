FactoryBot.define do
  factory :subscription do
    active_at { Time.now.utc }
    topics { [Faker::Lorem.word] }
    token { Faker::Internet.password(40, 60) }
  end
end
