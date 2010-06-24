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
    haml :index
  end
end

get '/contacts' do
  #@contacts = RestClient.get('https://www.google.com/m8/feeds/contacts/default/full/', :token => session[:authentication][:token])
  haml :contacts
end

get '/login' do
  oauth_token, oauth_token_secret = get_request_token
  session[:token_secret] = oauth_token_secret
  authorize_token(oauth_token)
end

get '/continue' do
  oauth_token, oauth_token_secret = get_access_token(params['oauth_token'], params['oauth_verifier'], session[:token_secret])
  session[:token_secret] = oauth_token_secret
  session[:authentication] = {:token => oauth_token, :token_secret => oauth_token_secret}
  redirect '/contacts'
end

get '/logout' do
  session[:authentication] = nil
  redirect '/'
end

def authenticated?
  !session[:authentication].nil?
end

def generate_nonce
  Array.new(10) { rand(256) }.pack('C*').unpack('H*').first
end

def generate_signature(method, target, oauth, consumer_secret, token_secret='')
  key = percent_encode(consumer_secret) + '&' + percent_encode(token_secret)
  puts 'Key:'
  puts key
  string = base_string(method, target, oauth)
  puts 'Base string:'
  puts string
  puts 'Signature:'
  signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), key, string)).chomp.gsub(/\n/,'') 
  puts signature
  signature
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
    'scope' => 'https://www.google.com/m8/feeds/',
    'oauth_callback' => 'http://localhost:4567/continue'
  }
  signature = generate_signature('POST', target, oauth, 'anonymous')
  result = CGI.parse(RestClient.post(target, oauth.merge('oauth_signature' => signature)))
  [result['oauth_token'].first, result['oauth_token_secret'].first]
end

def authorize_token(token)
  redirect 'https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token=' + token
end

def get_access_token(token, verifier, token_secret)
  target = 'https://www.google.com/accounts/OAuthGetAccessToken'
  oauth = {
    'oauth_consumer_key' => 'anonymous',
    'oauth_token' => token,
    'oauth_verifier' => verifier,
    'oauth_signature_method' => 'HMAC-SHA1',
    'oauth_timestamp' => Time.now.to_i.to_s,
    'oauth_nonce' => generate_nonce
  }
  signature = generate_signature('POST', target, oauth, 'anonymous', token_secret)
  result = CGI.parse(RestClient.post(target, oauth.merge('oauth_signature' => signature)))
  [result['oauth_token'].first, result['oauth_token_secret'].first]
end
