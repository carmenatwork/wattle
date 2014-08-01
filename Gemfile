source 'https://rubygems.org'

ruby File.read(".ruby-version").strip#'2.1.1'
gem 'rails', ">= 4.0"#, github: 'rails/rails', branch: 'v4.0.0.rc1'

gem 'pg'
gem 'postgres_ext'

gem "haml-rails"
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'


gem 'httpclient'
gem 'wat_catcher'#, path: "../wat_catcher"
gem 'kaminari'
gem 'kaminari-bootstrap'
gem 'omniauth-gplus'
gem 'secrets', :github => "austinfromboston/secrets"
gem 'state_machine'
gem 'user-agent'
gem 'redcarpet'

gem 'sass-rails',   '>= 4.0'
gem 'coffee-rails', '>= 4.0'
gem 'bootstrap-sass-rails'
gem "backbone-on-rails"
gem 'uglifier', '>= 1.0.3'
gem 'execjs'
gem 'therubyracer'
gem 'sidekiq'
gem 'slim', ">= 1.3.0", :require => false
gem 'sinatra', '>= 1.3.0', :require => false
gem 'highcharts-rails'
gem 'moment_ago'

gem 'puma'
gem 'newrelic_rpm'

gem 'paper_trail'

group :production do
  gem 'rails_12factor'
end

group :development do
  gem 'pivotal_git_scripts'
end

group :test, :development do
  gem 'awesome_print'
  gem 'rr', require: false
  gem "rspec-rails", "~> 2"
  gem 'fixture_builder'
end

group :test do
  gem 'email_spec'
  gem 'capybara'
  gem 'poltergeist'
  gem "poltergeist-suppressor"
  gem 'launchy'
end
