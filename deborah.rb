require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/models')
require 'oauth.rb'
require 'contact.rb'

enable :sessions

get '/' do
  if authenticated?
    redirect '/contacts'
  else
    haml :index
  end
end

get '/contacts' do
  @contacts = Contact.all(session[:authentication])
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

helpers ControllerHelper
