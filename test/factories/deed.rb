FactoryGirl.define do
  factory :deed do
    text { Faker::Hipster.sentence }
    names { [Faker::Internet.user_name.sub('.', '_')] }
    user
  end
end
