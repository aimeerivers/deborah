require 'rest_client'
require 'base64'
require 'openssl'
require 'connector.rb'

class Oauth
  include Connector

  def self.get_request_token(host, port)
    target = 'https://www.google.com/accounts/OAuthGetRequestToken'
    oauth = {
      'scope' => 'https://www.google.com/m8/feeds/',
      'oauth_callback' => "http://#{host}:#{port}/continue"
    }
    result = Connector::post_request(target, oauth)
    [result['oauth_token'].first, result['oauth_token_secret'].first]
  end

  def self.get_access_token(token, verifier, token_secret)
    target = 'https://www.google.com/accounts/OAuthGetAccessToken'
    oauth = {
      'oauth_token' => token,
      'oauth_verifier' => verifier
    }
    result = Connector::post_request(target, oauth, token_secret)
    [result['oauth_token'].first, result['oauth_token_secret'].first]
  end

end
