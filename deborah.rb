require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'geokit'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/models')
require 'oauth'
require 'contact'
require 'address'

enable :sessions

get '/' do
  if authenticated?
    redirect '/contacts'
  else
    haml :index
  end
end

get '/contacts' do
  @addresses = {}
  Contact.all(session[:authentication]).each do |c|
    @addresses[c.title] = c.addresses unless c.addresses.empty?
  end
  haml :contacts
end

get '/login' do
  oauth_token, oauth_token_secret = Oauth.get_request_token(request.host, request.port)
  session[:token_secret] = oauth_token_secret
  redirect "https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token=#{oauth_token}"
end

get '/continue' do
  oauth_token, oauth_token_secret = Oauth.get_access_token(params['oauth_token'], params['oauth_verifier'], session[:token_secret])
  session[:token_secret] = oauth_token_secret
  session[:authentication] = {:token => oauth_token, :token_secret => oauth_token_secret}
  redirect '/contacts'
end

get '/logout' do
  session[:authentication] = nil
  redirect '/'
end

module ControllerHelper
  def authenticated?
    !session[:authentication].nil?
  end
end

module ViewHelper
  def address_markers(addresses)
    output = "var infoWindow = new google.maps.InfoWindow();\n\n"
    index = 0
    addresses.each do |contact|
      addresses = contact[1]
      addresses.each do |address|
        lat = address.latitude
        lng = address.longitude
        unless lat.nil? || lng.nil?
          index += 1
          output << "var marker#{index} = new google.maps.Marker({position: new google.maps.LatLng(#{lat}, #{lng}), map: map, title: \"#{contact[0]}\"});\n"
          output << "google.maps.event.addListener(marker#{index}, 'click', function() { infoWindow.setContent(\"<strong>#{contact[0]}</strong><br />#{address.to_s}\"); infoWindow.open(map, marker#{index}); });\n\n"
        end
      end
    end
    output
  end
end

helpers ControllerHelper, ViewHelper
