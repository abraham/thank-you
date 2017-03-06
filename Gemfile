source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'coffee-rails', '~> 4.2'
gem 'fcm', '~> 0'
gem 'google_instance_id', '~> 0'
gem 'jbuilder', '~> 2.5'
gem 'oauth', '~> 0'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'rack-host-redirect'
gem 'rails-html-sanitizer'
gem 'rails', '5.1.0.beta1'
gem 'sassc-rails' # Use this instead of ruby-sass because of bug processing MDC
gem 'sentry-raven'
gem 'turbolinks', '~> 5'
gem 'twitter-text', '~> 1'
gem 'twitter', '~> 6'
gem 'uglifier', '~> 3'
gem 'webpacker', '~> 1'

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
