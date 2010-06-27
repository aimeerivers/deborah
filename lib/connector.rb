module Connector

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
