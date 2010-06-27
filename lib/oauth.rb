require 'rest_client'
require 'base64'
require 'openssl'
require 'connector.rb'

class Oauth
  include Connector

  def self.get_request_token(host, port)
    target = 'https://www.google.com/accounts/OAuthGetRequestToken'
    oauth = {
      'oauth_consumer_key' => 'anonymous',
      'oauth_nonce' => Connector::generate_nonce,
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamp' => Time.now.to_i.to_s,
      'scope' => 'https://www.google.com/m8/feeds/',
      'oauth_callback' => "http://#{host}:#{port}/continue"
    }
    result = Connector::make_request(target, oauth, 'anonymous')
    [result['oauth_token'].first, result['oauth_token_secret'].first]
  end

  def self.get_access_token(token, verifier, token_secret)
    target = 'https://www.google.com/accounts/OAuthGetAccessToken'
    oauth = {
      'oauth_consumer_key' => 'anonymous',
      'oauth_token' => token,
      'oauth_verifier' => verifier,
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamp' => Time.now.to_i.to_s,
      'oauth_nonce' => Connector::generate_nonce
    }
    result = Connector::make_request(target, oauth, 'anonymous', token_secret)
    [result['oauth_token'].first, result['oauth_token_secret'].first]
  end

end
