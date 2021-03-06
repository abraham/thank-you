# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

thank_names = Array.new(rand(40..50)).map { Faker::Twitter.screen_name }

users = Array.new(rand(40..50)).map do |_i|
  twitter_user = Faker::Twitter.user.merge(email: Faker::Internet.safe_email)
  twitter_user[:screen_name] = twitter_user[:screen_name]
  user = User.create(twitter_id: twitter_user[:id_str],
                     screen_name: twitter_user[:screen_name],
                     name: twitter_user[:name],
                     avatar_url: twitter_user[:profile_image_url_https],
                     data: twitter_user,
                     access_token: Faker::Internet.password(10, 20),
                     access_token_secret: Faker::Internet.password(20, 30),
                     email: Faker::Internet.safe_email,
                     default_avatar: twitter_user[:default_profile_image])
  Rails.logger.info "Error seeding user: #{user.errors.full_messages.to_sentence}" if user.new_record?

  user
end

Rails.logger.info "Seeded #{users.size} users"

deeds = Array.new(rand(40..50)).map do |_i|
  data = nil
  twitter_id = nil
  if rand(100) < 75
    data = Faker::Twitter.status(include_photo: rand(100) < 25)
    twitter_id = data[:id]
  end
  deed = Deed.create(text: Faker::Hipster.sentence,
                     names: thank_names.sample(rand(1..3)),
                     user: users.sample,
                     data: data,
                     twitter_id: twitter_id,
                     status: :published)
  Rails.logger.info "Error seeding deed: #{deed.errors.full_messages.to_sentence}" if deed.new_record?

  deed
end

Rails.logger.info "Seeded #{deeds.size} deeds"

links = deeds.map do |deed|
  deed_links = Array.new(rand(5)).map do |_i|
    link = Link.create(deed: deed,
                       user: deed.user,
                       text: Faker::Lorem.word,
                       url: Faker::Internet.url('example.com'))
    Rails.logger.info "Error seeding link: #{link.errors.full_messages.to_sentence}" if link.new_record?

    link
  end

  deed_links
end.flatten

Rails.logger.info "Seeded #{links.size} links"

thanks = deeds.map do |deed|
  deed_thanks = Array.new(rand(25)).map do |_i|
    user = users.sample
    next if user.thanked?(deed)

    status = Faker::Twitter.status
    thank = Thank.create(deed: deed,
                         text: deed.thank_text,
                         data: status,
                         twitter_id: status[:id],
                         user: user)

    Rails.logger.info "Error seeding thank: #{thank.errors.full_messages.to_sentence}" if thank.new_record?

    thank
  end

  deed_thanks
end.flatten

Rails.logger.info "Seeded #{thanks.size} thanks"
