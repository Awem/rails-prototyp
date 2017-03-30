source 'http://rubygems.org'
ruby '2.1.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'

# Use postgresql as the database for Active Record
gem 'pg', '0.18.4'

# Use rails-api
gem 'rails-api', '0.4.0'

# Use device for authentification
gem 'devise', '3.5.2'

# Support CORS
gem 'rack-cors', '0.4.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Ember
gem 'active_model_serializers', '~> 0.8.3'

# Paypal
gem 'paypal-sdk-adaptivepayments', '1.117.1'

# Gravatar
gem 'gravatarify', '3.1.1'

# File uploads
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'
gem 'fog-aws', '0.7.6'
gem 'file_validators', '2.0.2'

# DotEnv
gem 'dotenv-rails', '2.0.2', :groups => [:development, :test]

# Sample-User Creation
gem 'ffaker', '2.1.0'
gem 'forgery', '0.6.0'
gem 'geocoder', '1.2.12'

group :development do
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem 'tzinfo-data', '1.2015.7', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Cache
# gem 'redis'

# Debug
  gem 'better_errors', '2.1.1'
  gem 'binding_of_caller', '0.7.3.pre1'
  gem 'quiet_assets', '1.1.0'
  gem 'bullet', '4.14.10'

# Database dumps
  gem 'seed_dump', '3.2.2'

# Inspections
  gem 'rubocop', require: false
end

# Tests
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug'
  gem 'ruby-debug-ide', '0.6.0'
  gem 'debase', '0.2.2.beta6'

# Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '2.2.1'

  # gem 'rspec-rails'
  # gem 'rb-readline'
  # gem 'childprocess'
  # gem 'spring'
  # gem 'spring-commands-rspec'
end

group :test do
	# gem 'selenium-webdriver'
	# gem 'capybara'
	# gem 'factory_girl_rails'
	# gem 'database_cleaner'
end

group :production do
  # Heroku
  gem 'rails_12factor', '0.0.3'
end