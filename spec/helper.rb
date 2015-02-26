ENV["APP_ID"] = "123456789"
ENV["APP_API_KEY"] = "123456789"
ENV["APP_CANVAS_NAME"] = "testcampaignmonitor"
ENV["APP_SECRET"] = "mytestsessionsecret"

require "./application"
require "rspec"
require "rack/test"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.color = true
end
