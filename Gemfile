source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'arel', github: 'rails/arel'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
gem 'oauth', '~> 0'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'rails', github: 'rails/rails'
gem 'rails-html-sanitizer'
gem 'sass-rails', github: 'rails/sass-rails'
gem 'sentry-raven'
gem 'turbolinks', '~> 5'
gem 'twitter', '~> 6'
gem 'twitter-text', '~> 1'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', github: 'rails/webpacker'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_girl'
  gem 'faker', github: 'abraham/faker', branch: 'twitter'
  gem 'webmock'
end

group :development do
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rails_best_practices'
  gem 'rubocop'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby '2.3.1'
