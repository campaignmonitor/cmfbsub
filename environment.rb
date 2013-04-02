require 'bundler/setup'
require 'data_mapper'
require 'haml'
require 'sass'
require 'json'

require 'sinatra' unless defined?(Sinatra)

if development?
  require 'sinatra/reloader'
  require 'dotenv'
  Dotenv.load
end

configure do
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib") # Load models
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db"))
end
