require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'

enable :sessions

get '/' do
  if authenticated?
    redirect '/contacts'
  else
    haml :index
  end
end

get '/contacts' do
  'Your contacts will be shown here'
end

post '/login' do
  if authenticate(params[:token])
    redirect '/contacts'
  else
    redirect '/'
  end
end

get '/logout' do
  session[:authentication] = nil
  redirect '/'
end

def authenticated?
  !session[:authentication].nil?
end

def authenticate(token)
  response = JSON.parse(RestClient.post('https://rpxnow.com/api/v2/auth_info', :token => token, 'apiKey' => '2b28c508f47047b3fe69197e8cfedbd38606f5b0', :format => 'json', :extended => 'true'))
  if response['stat'] == 'ok'
    session[:authentication] = response.merge(:token => token)
    return true
  end
  return false
end
