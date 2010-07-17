require File.dirname(__FILE__) + '/../spec_helper'

describe Address do
  describe 'creating an address' do
    before do
      @address_string = "Buckingham Palace, London"
      @lat, @lng = mock(:lat), mock(:lng)
      @geocoded_address = mock(:geocode, :lat => @lat, :lng => @lng)
      Geokit::Geocoders::MultiGeocoder.stub!(:geocode => @geocoded_address)
    end

    it 'turns newlines into commas' do
      address = Address.new("Line 1 \nLine 2\nPostcode")
      address.to_s.should == "Line 1, Line 2, Postcode"
    end

    it 'looks up the geocoded adresss' do
      Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with(@address_string)
      address = Address.new(@address_string)
    end

    it 'sets the latitude and longitude' do
      address = Address.new(@address_string)
      address.latitude.should == @lat
      address.longitude.should == @lng
    end
  end
end
