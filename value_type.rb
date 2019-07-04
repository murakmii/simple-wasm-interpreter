class ValueType
  I32 = 0x7F
  I64 = 0x7E

  def self.decode(byte)
    case byte
    when I32
      Int.i32
    when I64
      Int.i64
    else
      raise "Invalid value type: #{byte}"
    end
  end
end
