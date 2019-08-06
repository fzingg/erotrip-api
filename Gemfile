source 'https://rubygems.org'
#source 'https://gems.ruby-hyperloop.org'
# source 'http://demo.kursator.com:9292'


git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.21'
gem 'activerecord-postgis-adapter'
gem 'geokit-rails'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'execjs'
# gem 'therubyracer', '~> 0.12.3'
gem 'uglifier', '>= 1.3.0'
# gem 'libv8', '~> 5.9'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# gem 'sprockets', '>=3.0.0.beta'
# gem 'sprockets-es6'

gem 'counter_culture', '~> 1.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'ransack'

gem 'font-awesome-sass'

gem 'carrierwave', '~> 1.0'
gem 'mini_magick'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil

gem 'babel-transpiler'

# Boostrap 4 integration
gem 'bootstrap', '~> 4.0.0.beta'
gem 'haml-rails'
gem 'jquery-rails'

# react-rails
# gem "react-rails", '~> 1.9.0'
# gem "react-rails", '>= 2.4.3'

# gem "webpacker"
gem 'webpacker', github: 'rails/webpacker'

gem 'devise'

gem 'figaro'

gem 'redis', '~> 3.0'
gem 'hiredis'
gem 'redis-namespace'

# gem 'hyperloop', '>= 0.5.8'
  # gem 'hyperloop', '1.0.0-lap7'
  # gem 'hyperloop', '1.0.0-lap8'
  # gem 'hyperloop', '1.0.0-lap11'
  # gem 'hyperloop', '1.0.0.pre.lap11'
  # gem 'hyperloop', '1.0.0-lap12'
# source 'https://gems.ruby-hyperloop.org' do
#   gem 'hyperloop', '1.0.0-lap17'
# end
# gem 'hyper-spec', '1.0.0-lap18'

# gem "opal", git: "https://github.com/janbiedermann/opal.git", branch: "master"
# gem "opal-activesupport", git: "https://github.com/janbiedermann/opal-activesupport.git", branch: "master"
# gem "opal-jquery", git: "https://github.com/opal/opal-jquery.git", branch: "master"
# gem "opal-rails", git: "https://github.com/opal/opal-rails.git", branch: "master"

#gem "opal", git: "https://github.com/janbiedermann/opal.git", branch: "master"
gem 'opal-activesupport', git: 'https://github.com/opal/opal-activesupport.git', branch: 'master'
gem "opal-jquery", git: "https://github.com/opal/opal-jquery.git", branch: "master"
gem "opal-rails"


# source 'https://gems.ruby-hyperloop.org' do
#   gem 'hyperloop', '1.0.0-lap18'
# end
# gem "hyper-store", git: "https://github.com/janbiedermann/hyper-store.git", branch: "1_0_0"
# gem "hyper-react", git: "https://github.com/janbiedermann/hyper-react.git", branch: "1_0_0"

gem 'hyper-component', '1.0.0.lap27'
gem 'hyper-router', '4.2.6.lap27'
gem 'hyper-store' , '1.0.0.lap27'
gem 'hyperloop-config', '1.0.0.lap27'

gem 'opal-uri'

# gem 'hyper-operation', git: "https://github.com/ruby-hyperloop/hyper-operation", branch: '1_0_0'
# gem 'hyper-react', git: "https://github.com/ruby-hyperloop/hyper-react", branch: '1_0_0'
# gem 'hyper-mesh', git: "https://github.com/ruby-hyperloop/hyper-mesh", branch: '1_0_0'

# gem 'hyperloop-config', git: 'https://github.com/janbiedermann/hyperloop-config', branch: '1_0_0'
# gem 'hyper-react', git: 'http://github.com/janbiedermann/hyper-react.git', branch: '1_0_0'

# gem 'sprockets', git: 'https://github.com/janbiedermann/sprockets', branch: '3.x_perf_proper_mega'
# gem 'hyperloop', '0.15.0-autobahn-a7'

# gem 'hyper-mesh',      path: '/Users/andriivotiakov/Workspace/hyper-mesh'
# gem 'hyper-mesh',      git: 'https://github.com/votiakov/hyper-mesh'
# gem 'hyper-operation', path: '/Users/andriivotiakov/Workspace/erotrip/erotrip-api/hyper-operation-0.5.12'

# gem 'hyper-operation', git: 'https://github.com/votiakov/hyper-operation', ref: '85e867e8385754bcb60165d914cc0fc731a94e1a'

# gem 'hyperloop'

gem "annotate", git: 'https://github.com/enginearch/annotate_models.git', ref: '483c8a2a0eb2e1c400dd6c6b7de11a57f2f7b5ad'
# gem "annotate", path: "/Users/andriivotiakov/Workspace/annotate_models"

# gem "skylight"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '~> 2.13'
  # gem 'selenium-webdriver'
end

group :development do

  # for hot reloading
  gem 'opal_hot_reloader', git: 'https://github.com/fkchang/opal-hot-reloader.git'
  gem 'foreman'
  # -----------------

  # gem 'rubycritic'
  # gem 'hyper-console'
  # gem "rails-erd"

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  # gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano', '= 3.8.2'
  # gem 'capistrano-yarn'
  # gem 'capistrano-nvm', require: false
  gem 'capistrano-local-precompile', '~> 1.0.0', require: false
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rails-db'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-bundler', '~> 1.2'
  gem 'capistrano-sidekiq'
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
  gem "capistrano-db-tasks", '~> 0.4', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
