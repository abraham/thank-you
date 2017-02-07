# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users = (1..50).map do |_i|
  twitter_user = Faker::Twitter.user
  User.create(twitter_id: twitter_user[:id_str],
              screen_name: Faker::Internet.user_name,
              name: Faker::Name.name,
              avatar_url: Faker::Avatar.image(twitter_user[:id_str], '48x48'),
              data: twitter_user,
              access_token: Faker::Internet.password(10, 20),
              access_token_secret: Faker::Internet.password(20, 30))
end

50.times do |_i|
  user = users.sample
  name = Faker::Internet.user_name
  deed = Deed.create(text: "Thank you @#{name} for #{Faker::Hipster.sentence}",
                       name: name,
                       user: user)
  rand(5).times do |_i|
    Link.create(deed: deed,
                user: user,
                text: Faker::Lorem.words(2).join(' '),
                url: Faker::Internet.url('example.com'))
  end

  rand(50).times do |_i|
    tweet = Faker::Twitter.status
    # NOTE: some of these fail due to thank/user uniqueness constraints
    Thank.create(deed: deed,
                 text: deed.text,
                 tweet_id: tweet[:id_str],
                 data: tweet,
                 user: users.sample)
  end
end
