class Address

  attr_reader :latitude, :longitude

  def initialize(address_string)
    @address = address_string.split("\n").map{|line| line.strip}.join(', ')
    geocode = Geokit::Geocoders::MultiGeocoder.geocode(@address)
    @latitude = geocode.lat
    @longitude = geocode.lng
  end

  def to_s
    @address
  end

end
