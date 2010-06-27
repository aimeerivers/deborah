require 'connector.rb'

class Contact
  include Connector

  def self.all(authentication)
    target = 'https://www.google.com/m8/feeds/contacts/default/full'
    params = {
      'oauth_token' => authentication[:token]
    }
    Connector::get_request(target, params, authentication[:token_secret])
  end

end
