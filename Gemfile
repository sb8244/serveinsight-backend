source 'https://rubygems.org'

ruby '2.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'

gem 'pg'
gem 'sidekiq'
gem 'sinatra', :require => nil
gem 'foreman'
gem 'puma'

group :development, :test do
  gem 'byebug'
  gem 'pry-rails'
  gem 'factory_girl_rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :test do
  gem 'rspec-rails'
  gem 'db-query-matchers'
  gem 'timecop'
end

gem 'rails_12factor', group: :production

gem 'rack-cors', :require => 'rack/cors'
gem 'omniauth-google-oauth2', branch: 'master' # master fixes redirect issues with satellize
gem 'dotenv-rails'
gem 'jwt'
gem 'active_model_serializers', '< 0.9'
gem 'responders', '~> 2.0'
gem 'acts_as_commentable'

gem 'chronic'
gem 'httparty'
