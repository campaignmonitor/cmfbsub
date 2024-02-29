source "https://rubygems.org"
ruby "2.2.2"

gem "rake"
gem "multi_json", "~> 1.3"
gem "rack", "~> 2.2.8", ">= 2.2.8.1"
gem "rack-test", ">= 1.0.0"
gem "sinatra", "2.0.2"
gem "sinatra-reloader"
gem "haml"
gem "sass"
gem "omniauth-facebook", "~> 5.0", ">= 5.0.0"
gem "yajl-ruby", "~> 1.3.1"
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
