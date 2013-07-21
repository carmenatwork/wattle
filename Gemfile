source 'https://rubygems.org'

gem 'rails', ">= 4.0"#, github: 'rails/rails', branch: 'v4.0.0.rc1'

gem 'pg'

gem "haml-rails"
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'


gem 'httpclient'
gem 'wat_catcher'
gem 'kaminari'
gem 'omniauth-gplus'
gem 'secrets', :github => "austinfromboston/secrets"
gem 'state_machine'
gem 'user-agent'

gem 'sass-rails',   '>= 4.0'
gem 'coffee-rails', '>= 4.0'
gem 'bootstrap-sass', '>= 2.3.1.0'
gem "backbone-on-rails"
gem 'uglifier', '>= 1.0.3'
gem 'execjs'
gem 'therubyracer'
gem 'sidekiq'
gem 'slim', ">= 1.3.0", :require => false
gem 'sinatra', '>= 1.3.0', :require => false


group :production do
  gem 'passenger'
end

group :development do
  gem 'mailcatcher'
  gem 'debugger'
end

group :test, :development do
  gem 'rr', require: false
  gem "rspec-rails", ">= 2.0"
  gem 'fixture_builder'
  gem 'thin'
end

group :test do
  gem 'email_spec'
end
