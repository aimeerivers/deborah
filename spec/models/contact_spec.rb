require File.dirname(__FILE__) + '/../spec_helper'

describe Contact do

  describe 'creating a new contact' do
    context 'name' do
      it 'populates the name when one is provided' do
        contact_name = 'CONTACT NAME'
        contact = Contact.new('title' => contact_name)
        contact.name.should == contact_name
      end

      it 'does not populate the name unless it is a string' do
        contact = Contact.new('title' => {'type' => 'text'})
        contact.name.should be_nil
      end
    end

    context 'email' do
      it 'populates the email address' do
        email = mock(:email)
        contact = Contact.new('gd:email' => {'primary' => 'true', 'address' => email})
        contact.email.should == email
      end

      it 'does not populate the email address if one does not exist' do
        contact = Contact.new()
        contact.email.should be_nil
      end

      it 'populates the primary email address if there is more than one' do
        primary_email = mock(:email)
        contact = Contact.new('gd:email' => [{'primary' => 'true', 'address' => primary_email}, {'address' => 'other email'}])
        contact.email.should == primary_email
      end
    end

    context 'address' do
      it 'populates the address if there is one' do
        address = 'ADDRESS'
        contact = Contact.new('gd:postalAddress' => address)
        contact.address.should == address
      end

      it 'turns newlines into commas' do
        address = "Line 1 \nLine 2\nPostcode"
        contact = Contact.new('gd:postalAddress' => address)
        contact.address.should == "Line 1, Line 2, Postcode"
      end

      it 'does not populate the address if one does not exist' do
        contact = Contact.new()
        contact.address.should be_nil
      end
    end
  end

  describe 'contact title' do
    it 'uses the name if it has one' do
      contact_name = 'CONTACT NAME'
      contact = Contact.new('title' => contact_name)
      contact.title.should == contact_name
    end

    it 'uses the email if there is no name' do
      email = mock(:email)
      contact = Contact.new('gd:email' => {'primary' => 'true', 'address' => email})
      contact.title.should == email
    end
  end

  describe 'fetching contacts from Google' do
    before do
      @result = ''
      Connector.stub!(:get_request => @result)
      Crack::XML.stub!(:parse => {'feed' => {'entry' => []}})
    end

    it 'makes the request to Google Contacts' do
      Connector.should_receive(:get_request).with('https://www.google.com/m8/feeds/contacts/default/thin', anything, anything)
      Contact.all({})
    end

    it 'parses the results' do
      Crack::XML.should_receive(:parse).with(@result)
      Contact.all({})
    end

    it 'creates contacts from the results' do
      entry1 = mock(:entry)
      entry2 = mock(:entry)
      Crack::XML.stub!(:parse => {'feed' => {'entry' => [entry1, entry2]}})
      Contact.should_receive(:new).with(entry1)
      Contact.should_receive(:new).with(entry2)
      Contact.all({})
    end

    it 'provides an array of contacts' do
      contact = mock(:contact)
      Crack::XML.stub!(:parse => {'feed' => {'entry' => [mock]}})
      Contact.stub!(:new => contact)
      Contact.all({}).should == [contact]
    end
  end
end
