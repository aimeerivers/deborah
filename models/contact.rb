require 'connector.rb'
require 'crack/xml'

class Contact
  include Connector

  attr_reader :name
  attr_reader :email
  attr_reader :addresses

  def initialize(params={})
    @name = params['title'] if params['title'].is_a? String
    @email = parse_email(params['gd:email'])
    @addresses = build_addresses(params['gd:postalAddress'])
  end

  def title
    return name unless name.nil?
    email
  end

  def self.all(authentication)
    target = 'https://www.google.com/m8/feeds/contacts/default/thin'
    params = {
      'oauth_token' => authentication[:token],
      'max-results' => 1000
    }
    result = Crack::XML.parse(Connector::get_request(target, params, authentication[:token_secret]))
    result['feed']['entry'].map {|entry| Contact.new(entry)}
  end

  private

  def parse_email(email)
    return nil if email.nil?
    if email.is_a? Array
      email = email.select{|e| e.has_key?('primary')}.first
    end
    email['address']
  end

  def build_addresses(addresses)
    return [] if addresses.nil?
    addresses = [addresses] if addresses.is_a? String
    addresses.map{|a| Address.new(a)}
  end

end
