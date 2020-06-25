source 'https://rubygems.org'

gem 'dotenv-rails', :groups => [:development, :test, :production]

# gem 'cocoon' # remove?
gem 'qa'
# use latest qa code - seems to be a problem using this in production with phusion-passenger
# gem 'qa', :git => 'https://github.com/projecthydra-labs/questioning_authority.git', :branch => 'master'

# gem 'hydra', '9.0.0'
# Install hydra gems individually to get latest versions
gem 'active-fedora', '10.3.0'
gem 'hydra-head'
gem 'om', '~> 3.1.0'
gem 'solrizer'
gem 'rsolr'
gem 'blacklight'
gem 'active-triples'
gem 'nom-xml'

gem 'active_fedora-noid'
#gem 'active_fedora-noid', '1.0.0'

gem "nokogiri", ">= 1.10.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0'
gem 'sprockets', '~> 3.7.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.13'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  #gem 'byebug'
  gem 'pry-rails'
  gem 'pry-byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rspec-rails'
  gem 'jettywrapper'
  gem 'thin'
  gem 'xray-rails'
end

gem "devise", ">= 4.7.1"
gem 'devise-guests', '~> 0.3'
gem 'smarter_csv'
