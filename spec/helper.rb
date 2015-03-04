require "simplecov"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
]
SimpleCov.add_filter "spec"
SimpleCov.start

ENV["APP_ID"] = "123456789"
ENV["APP_API_KEY"] = "testapikey"
ENV["APP_CANVAS_NAME"] = "testcampaignmonitor"
ENV["APP_SECRET"] = "mytestsessionsecret"

require "./application"
require "rspec"
require "rack/test"
require "webmock/rspec"

WebMock.disable_net_connect!

RSpec.configure do |conf|
  conf.color = true
  conf.include Rack::Test::Methods
end
