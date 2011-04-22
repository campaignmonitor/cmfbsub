require 'sinatra'
require 'haml'
require 'omniauth/oauth'
require "sinatra/reloader" if development?
require 'yaml' if development?

Dir.glob('lib/*.rb') do |lib|
  require lib
end

if production?
  APP_ID = ENV['APP_ID']
  APP_SECRET = ENV['APP_SECRET']
else
  config = YAML.load_file('config.yaml')
  APP_ID = config['APP_ID']
  APP_SECRET = config['APP_SECRET']
end

use OmniAuth::Builder do
  provider :facebook, APP_ID, APP_SECRET, {}
end

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  enable :sessions
  # All requests made from the Facebook iframe are now POST requests
  use Rack::Facebook, { :secret => APP_SECRET }
end

helpers do
  def media_version
    "201104221530"
  end
  
  def partial(name, locals={})
    haml "_#{name}".to_sym, :layout => false, :locals => locals
  end
end

before do
  content_type :html, :charset => 'utf-8'
end

error do
  haml :error
end

not_found do
  haml :not_found
end

get '/' do
  haml :index
end

get '/tab' do
  haml :tab
end

get '/edit' do
  haml :edit
end

get '/auth/facebook/callback' do
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

get '/auth/failure' do
  clear_session
  session['fb_error'] = 'In order to use this application you must allow us access to your Facebook basic information'
  redirect '/'
end

get '/logout' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end

%w(reset screen).each do |style|
  get "/#{style}.css" do
    content_type :css, :charset => 'utf-8'
    path = "public/sass/#{style}.scss"
    last_modified File.mtime(path)
    scss File.read(path)
  end
end