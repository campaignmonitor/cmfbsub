require 'sinatra'
require 'haml'
require 'omniauth/oauth'
require 'mogli'
require 'createsend'
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
  client_options = production? ? {:ssl => {:ca_path => "/etc/ssl/certs"}} : {}
  provider :facebook, APP_ID, APP_SECRET, {:client_options => client_options}
end

configure :production do
  Ohm.connect(:url => ENV["REDISTOGO_URL"])
end

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  enable :sessions
  # Custom middleware for a Facebook canvas app
  use Rack::Facebook, { :secret => APP_SECRET }
  CreateSend.base_uri "https://api.createsend.com/api/v3"
end

helpers do
  def media_version
    "201104241106"
  end
  
  def partial(name, locals={})
    haml "_#{name}".to_sym, :layout => false, :locals => locals
  end

  def needs_auth
    redirect '/auth/facebook' unless has_auth?
  end

  def has_auth?
    !session['fb_auth'].nil?
  end

  def default_subscribe_form_message
    "Enter your details to subscribe to our mailing list"
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

def get_user(user_id)
  Mogli::User.find(user_id, Mogli::Client.new(session['fb_token']))
end

def get_page(page_id)
  Mogli::Page.find(page_id, Mogli::Client.new(session['fb_token']))
end

get '/' do
  needs_auth

  @user = get_user("me")
  @pages = @user.accounts
  if session[:confirmation_message]
    @confirmation_message = session[:confirmation_message]
    session[:confirmation_message] = nil
  end
  haml :index
end

get '/page/:page_id/?' do |page_id|
  needs_auth

  # Check for an existing subscribe form for the page
  @found = SubscribeForm.find(:page_id => page_id).to_a
  @sf = @found ? @found.first : nil
  @user = get_user("me")
  @pages = @user.accounts
  @page = get_page(page_id)
  haml :page
end

post '/page/:page_id/?' do |page_id|
  needs_auth

  @user = get_user("me")
  # Update the values of the subscribe form if it already exists
  # otherwise, create a new subscribe form for the page
  @found = SubscribeForm.find(:page_id => page_id).to_a
  @sf = @found ? @found.first : nil
  begin
    # Validate input by attempting to get list details
    CreateSend.api_key params[:apikey].strip
    @list = CreateSend::List.new(params[:listid].strip).details

    if @sf
      @sf.api_key = params[:apikey].strip
      @sf.list_id = params[:listid].strip
      @sf.save
    else
      SubscribeForm.create :user_id => @user.id, :page_id => page_id,
        :api_key => params[:apikey].strip, :list_id => params[:listid].strip
    end
    @page = get_page(page_id)
    session[:confirmation_message] = "Thanks, you successfully saved your subscribe form for #{@page.name}."
    redirect '/'

    rescue CreateSend::CreateSendError, CreateSend::ClientError, 
      CreateSend::ServerError, CreateSend::Unavailable => cse
      p "CreateSend error: #{cse}"
      @error_message = "Sorry, your API Key/List ID combination is invalid. Please try again."
      @page = get_page(page_id)
      haml :page
  end
end

get '/tab/?' do
  @page_id = params['facebook'] ? params['facebook']['page']['id'] : ''
  @found = SubscribeForm.find(:page_id => @page_id).to_a
  @sf = @found ? @found.first : nil

  haml :tab
end

post '/subscribe/:page_id/?' do |page_id|
  @found = SubscribeForm.find(:page_id => page_id).to_a
  @sf = @found ? @found.first : nil
  redirect '/tab' unless @sf

  begin
    @page_id = page_id
    CreateSend.api_key @sf.api_key
    CreateSend::Subscriber.add @sf.list_id, params[:email].strip, params[:name].strip, [], true
    @confirmation_message = "Thanks for subscribing to our list."
    haml :tab

    rescue Exception => e
      p "Error: #{e}"
      @error_message = "Sorry, there was a problem subscribing you to our list."
      @name = params[:name].strip
      @email = params[:email].strip
      haml :tab
  end
end

get '/auth/facebook/callback/?' do
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  session[:admin] = false
  redirect '/'
end

get '/auth/failure/?' do
  clear_session
  session['fb_error'] = 'In order to use this application you must permit access to your basic information.'
  redirect '/'
end

get '/logout/?' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
  session[:admin] = false
end

%w(reset screen).each do |style|
  get "/#{style}.css" do
    content_type :css, :charset => 'utf-8'
    path = "public/sass/#{style}.scss"
    last_modified File.mtime(path)
    scss File.read(path)
  end
end