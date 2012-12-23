source 'https://rubygems.org'

gem 'sinatra', '~> 1.3'
gem 'thin', '~> 1.5'
gem 'ponder', :git => 'git://github.com/tbuehlmann/ponder.git'
gem 'datamapper', '~> 1.2'
gem 'haml', '~> 3.1'

group :development do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
  gem 'sinatra-contrib', '~> 1.3'
  gem 'pry'
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end
