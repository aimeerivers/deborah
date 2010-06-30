class Address

  def initialize(address_string)
    @address = address_string.split("\n").map{|line| line.strip}.join(', ')
  end

  def to_s
    @address
  end

end
