source "https://rubygems.org"
ruby "1.9.3"

gem "rake"
gem "rack", "~> 1.3"
gem "sinatra", "1.3.3"
gem "sinatra-reloader"
gem "haml"
gem "sass"
gem "oa-oauth", "~> 0.3"
gem "yajl-ruby"
gem "mogli", "~> 0.0.36"
gem "createsend", "~> 3.1"
gem "data_mapper"
gem "json"
gem "unicorn"

group :development, :test do
  gem "dm-sqlite-adapter"
  gem "rspec"
  gem "webmock"
end

group :production do
  gem "dm-postgres-adapter"
  gem "pg"
  gem "newrelic_rpm"
end
