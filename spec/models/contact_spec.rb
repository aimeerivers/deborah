require File.dirname(__FILE__) + '/../spec_helper'

describe Contact do
  describe 'fetching contacts from Google' do
    it 'makes the request to Google Contacts' do
      Connector.should_receive(:get_request).with('https://www.google.com/m8/feeds/contacts/default/full', anything, anything)
      Contact.all({})
    end
  end
end
