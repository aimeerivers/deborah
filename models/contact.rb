require 'connector.rb'
require 'crack/xml'

class Contact
  include Connector

  attr_reader :name
  attr_reader :email
  attr_reader :address

  def initialize(params={})
    @name = params['title'] if params['title'].is_a? String
    @email = parse_email(params['gd:email'])
    @address = parse_address(params['gd:postalAddress'])
  end

  def title
    return name unless name.nil?
    email
  end

  def self.all(authentication)
    target = 'https://www.google.com/m8/feeds/contacts/default/thin'
    params = {
      'oauth_token' => authentication[:token]
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

  def parse_address(address)
    return nil unless address.is_a? String
    address.split("\n").map{|line| line.strip}.join(', ')
  end

end
