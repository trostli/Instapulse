require "sinatra"
require "instagram"
require "json"

begin
  require 'dotenv'
  Dotenv.load(".env")
  rescue
end

begin
  require "awesome_print"
  rescue
end

enable :sessions



Instagram.configure do |config|
  config.client_id = ENV['INSTA_ID']
  config.client_secret = ENV['INSTA_SECRET']
end

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => ENV['CALLBACK_URL'])
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => ENV['CALLBACK_URL'])
  session[:access_token] = response.access_token
  redirect "/feed"
end

get "/feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user

  html = "<h1>#{user.username}'s recent photos</h1>"
  for media_item in client.user_recent_media
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end





get "/search" do
  erb :search
end

post "/search" do
  @media = Instagram.media_search("37.768815","-122.439736", {distance: 5000, max_timestamp: 1383288690, min_timestamp: 1383288660})
  output = []

  @media.each do |photo|
    lat = photo.location.latitude
    long = photo.location.longitude
    output << [lat,long]
  end
  output.to_json
end

