require 'rest_client'
require 'base64'
require 'openssl'

class Oauth

  def self.get_request_token
    target = 'https://www.google.com/accounts/OAuthGetRequestToken'
    oauth = {
      'oauth_consumer_key' => 'anonymous',
      'oauth_nonce' => generate_nonce,
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamp' => Time.now.to_i.to_s,
      'scope' => 'https://www.google.com/m8/feeds/',
      'oauth_callback' => 'http://localhost:4567/continue'
    }
    result = make_request(target, oauth, 'anonymous')
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
      'oauth_nonce' => generate_nonce
    }
    result = make_request(target, oauth, 'anonymous', token_secret)
    [result['oauth_token'].first, result['oauth_token_secret'].first]
  end

  private

  def self.generate_nonce
    Array.new(10) { rand(256) }.pack('C*').unpack('H*').first
  end

  def self.make_request(target, oauth, consumer_secret, token_secret='')
    signature = generate_signature('POST', target, oauth, consumer_secret, token_secret)
    CGI.parse(RestClient.post(target, oauth.merge('oauth_signature' => signature)))
  end

  def self.generate_signature(method, target, oauth, consumer_secret, token_secret='')
    key = percent_encode(consumer_secret) + '&' + percent_encode(token_secret)
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), key, base_string(method, target, oauth))).chomp.gsub(/\n/,'')
  end

  def self.base_string(method, target, oauth)
    pairs = []
    oauth.sort.each do |key, val|
      pairs.push("#{key}=#{percent_encode(val.to_s)}")
    end
    result = "#{method}&#{percent_encode(target)}&#{percent_encode(pairs.join('&'))}"
    result
  end

  def self.percent_encode(string)
    URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
  end

end
