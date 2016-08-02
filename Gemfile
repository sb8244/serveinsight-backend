source 'https://rubygems.org'

ruby '2.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7'

gem 'pg'
gem 'sidekiq'
gem 'redis-namespace'
gem 'sinatra', :require => nil
gem 'foreman'
gem 'puma'
gem 'newrelic_rpm'

gem 'kaminari'
gem 'indefinite_article'
gem 'premailer-rails'
gem 'nokogiri'

group :development, :test do
  gem 'byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

# In production for seeds
gem 'factory_girl_rails'
gem 'faker'

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'brakeman', require: false
end

group :test do
  gem 'db-query-matchers'
  gem 'timecop'
  gem 'mock_redis'
end

group :production do
  gem 'bugsnag'
  gem 'rails_12factor'
end

gem 'rack-cors', :require => 'rack/cors'
gem 'omniauth-google-oauth2', branch: 'master' # master fixes redirect issues with satellize
gem 'dotenv-rails'
gem 'jwt'
gem 'active_model_serializers', '< 0.9'
gem 'responders', '~> 2.0'
gem 'acts_as_commentable'

gem 'devise'

gem 'chronic'
gem 'httparty'
