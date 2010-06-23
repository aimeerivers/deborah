require 'rubygems'
require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'
require 'base64'
require 'openssl'

enable :sessions

get '/' do
  if authenticated?
    redirect '/contacts'
  else
    redirect '/login'
  end
end

get '/contacts' do
  @contacts = RestClient.get('http://www-opensocial.googleusercontent.com/api/people/@me/@all', :token => session[:authentication][:token])
  haml :contacts
end

get '/login' do
  oauth_token, oauth_token_secret = get_request_token
  authorize_token(oauth_token)
end

get '/continue' do
  @target = 'https://www.google.com/accounts/OAuthGetAccessToken'
  @oauth = {
    'oauth_consumer_key' => 'anonymous',
    'oauth_token' => params['oauth_token'],
    'oauth_verifier' => params['oauth_verifier'],
    'oauth_timestamp' => Time.now.to_i.to_s,
    'oauth_nonce' => generate_nonce
  }
  @signature = generate_signature('POST', @target, @oauth)
  haml :index
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

def generate_nonce
  Array.new(5) { rand(256) }.pack('C*').unpack('H*').first
end

def generate_signature(method, target, oauth)
  string = base_string(method, target, oauth)
  puts string
  Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), 'anonymous&', string)).chomp.gsub(/\n/,'') 
end

def base_string(method, target, oauth)
  pairs = []
  oauth.sort.each do |key, val|
    pairs.push("#{key}=#{percent_encode(val.to_s)}")
  end
  result = "#{method}&#{percent_encode(target)}&#{percent_encode(pairs.join('&'))}"
  result
end

def percent_encode(string)
  URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
end

def get_request_token
  target = 'https://www.google.com/accounts/OAuthGetRequestToken'
  oauth = {
    'oauth_consumer_key' => 'anonymous',
    'oauth_nonce' => generate_nonce,
    'oauth_signature_method' => 'HMAC-SHA1',
    'oauth_timestamp' => Time.now.to_i.to_s,
    'scope' => 'http://www-opensocial.googleusercontent.com/api/people',
    'oauth_callback' => 'http://localhost:4567/continue'
  }
  signature = generate_signature('POST', target, oauth)
  result = CGI.parse(RestClient.post(target, oauth.merge('oauth_signature' => signature)))
  [result['oauth_token'].first, result['oauth_token_secret'].first]
end

def authorize_token(token)
  redirect 'https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token=' + token
end

def get_access_token(token, verifier)
  result = CGI.parse(RestClient.post(target, oauth.merge('oauth_signature' => signature)))
  raise result.inspect
end
