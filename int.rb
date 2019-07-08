class Int
  attr_reader :bits

  def self.i32
    @i32 ||= new(32)
  end

  def self.i64
    @i64 ||= new(64)
  end

  def initialize(bits)
    @bits = bits
  end

  def default_value
    0
  end

  def ==(int)
    self.class == int.class && bits == int.bits
  end

  def inspect
    "i#{bits}"
  end
end
