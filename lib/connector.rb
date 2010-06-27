module Connector

  def self.generate_nonce
    Array.new(10) { rand(256) }.pack('C*').unpack('H*').first
  end

  def self.post_request(target, params, token_secret='')
    merge_params!(params)
    signature = generate_signature('POST', target, params, 'anonymous', token_secret)
    CGI.parse(RestClient.post(target, params.merge('oauth_signature' => signature)))
  end

  def self.get_request(target, params, token_secret='')
    merge_params!(params)
    signature = generate_signature('GET', target, params, 'anonymous', token_secret)
    target = "#{target}?#{query_string(params)}&oauth_signature=#{signature}"
    RestClient.get(target, :content_type => 'application/atom+xml')
  end

  def self.merge_params!(params)
    params.merge!({
      'oauth_consumer_key' => 'anonymous',
      'oauth_nonce' => generate_nonce,
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamp' => Time.now.to_i.to_s
    })
  end

  def self.generate_signature(method, target, params, consumer_secret, token_secret='')
    key = percent_encode(consumer_secret) + '&' + percent_encode(token_secret)
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), key, base_string(method, target, params))).chomp.gsub(/\n/,'')
  end

  def self.base_string(method, target, params)
    "#{method}&#{percent_encode(target)}&#{percent_encode(query_string(params))}"
  end

  def self.query_string(params)
    pairs = []
    params.sort.each do |key, val|
      pairs.push("#{key}=#{percent_encode(val.to_s)}")
    end
    pairs.join('&')
  end

  def self.percent_encode(string)
    URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") ).gsub('*', '%2A')
  end

end
