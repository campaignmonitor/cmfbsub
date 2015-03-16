source "https://rubygems.org"
ruby "2.1.5"

gem "rake"
gem "multi_json", "~> 1.3"
gem "rack", "~> 1.3"
gem "sinatra", "1.3.3"
gem "sinatra-reloader"
gem "haml"
gem "sass"
gem "omniauth-facebook", "~> 2.0"
gem "yajl-ruby"
gem "koala", "~> 1.11"
gem "createsend", "~> 3.1"
gem "data_mapper"
gem "unicorn"

group :development, :test do
  gem "dm-sqlite-adapter"
  gem "rspec"
  gem "webmock"
  gem "simplecov", :require => false
end

group :production do
  gem "dm-postgres-adapter"
  gem "pg"
  gem "newrelic_rpm"
end
