require File.dirname(__FILE__) + '/../spec_helper'

describe Address do
  describe 'creating an address' do
    it 'turns newlines into commas' do
      address = Address.new("Line 1 \nLine 2\nPostcode")
      address.to_s.should == "Line 1, Line 2, Postcode"
    end
  end
end
