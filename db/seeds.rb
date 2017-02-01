# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

50.times do |_i|
  name = Faker::Internet.user_name
  thank = Thank.create(text: "Thank you @#{name} for #{Faker::Hipster.sentence}",
                       name: name)
  rand(50).times do |_i|
    Ditto.create(thank: thank,
                 text: thank.text,
                 tweet_id: Faker::Number.number(10),
                 data: { fake_tweet: true })
  end
end
