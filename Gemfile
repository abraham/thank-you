# frozen_string_literal: true

ruby '2.5.1'

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'fcm'
gem 'google_instance_id'
gem 'jbuilder'
gem 'oauth'
gem 'pg', '~> 1'
gem 'puma'
gem 'rack-host-redirect'
gem 'rails'
gem 'rails-html-sanitizer'
gem 'sass-rails'
gem 'sentry-raven'
gem 'turbolinks'
gem 'twitter'
gem 'twitter-text', '~> 1'
gem 'uglifier'
gem 'webpacker'

# Temp pins
gem 'http', '~> 2'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot'
  gem 'faker'
  gem 'webmock'
end

group :development do
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'rails_best_practices'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
